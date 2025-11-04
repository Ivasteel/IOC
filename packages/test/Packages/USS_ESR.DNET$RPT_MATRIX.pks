/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_MATRIX
IS
    -- Author  : IO
    -- Created : 16.02.2022
    -- Purpose : "Звіти" по відомостях для друку на матричних принтерах

    -- Структуры для нумерации списков ведомостей на почту
    TYPE t_b1m_record IS RECORD
    (
        prs_id                   pr_sheet.prs_id%TYPE,
        pp_date                  DATE,
        prs_sum                  pr_sheet.prs_sum%TYPE,
        org_id                   payroll.com_org%TYPE,
        prs_pc_num               pr_sheet.prs_pc_num%TYPE,
        prs_inn                  pr_sheet.prs_inn%TYPE,
        prs_pib                  VARCHAR2 (152 CHAR),
        prs_index                uss_ndi.v_ndi_post_office.npo_index%TYPE,
        ncn_name                 uss_ndi.v_ndi_comm_node.ncn_name%TYPE,
        address                  VARCHAR2 (500 CHAR),
        dlvr_code                uss_ndi.v_ndi_delivery.nd_code%TYPE,
        is_payed_on_post         INTEGER,
        pnf_pasp                 VARCHAR2 (30),   -- document.doc_number%type,
        ind_lim_value            NUMBER (14, 2), -- v_nsi_index.ind_lim_value%type,
        prs_num                  pr_sheet.prs_num%TYPE,
        pp_pn                    NUMBER,
        d                        CHAR (1),
        is_high_prior_recieve    CHAR (1),
        pp_day                   INTEGER,
        per_month                VARCHAR2 (30),
        per_year                 VARCHAR2 (10),
        opfu_name                v_opfu.ORG_NAME%TYPE,
        org_code                 v_opfu.ORG_CODE%TYPE,
        pr_tp                    uss_ndi.v_ddn_pr_tp.DIC_SNAME%TYPE
    );

    TYPE t_b1m_table IS TABLE OF t_b1m_record
        INDEX BY PLS_INTEGER;

    CURSOR c_b1m (p_pr_id payroll.pr_id%TYPE--p_prs_pay_tp pr_sheet.prs_pay_tp%type,
                                            --p_pr_st      payroll.pr_st%type
                                            --p_org_id     payroll.com_org%type,
                                            --p_asopd      number default null
                                            )
    IS
        WITH
            t1
            AS
                (  SELECT PRS_NUM,
                          PP_PN,
                          ORG_ID,
                          PRS_PC_NUM,
                          PRS_INN,
                          PRS_PASP,
                          PRS_PC,
                          ADR_OFFICE,
                          PRS_BLOCK,
                          ADR_BUILDING,
                          STLM_NAME,
                          UL_NAME,
                          PP_DATE,
                          PRS_PIB,
                          PRS_INDEX,
                          NCN_NAME,
                          ADDRESS,
                          DLVR_CODE_F,
                          IS_PAYED_ON_POST,
                          ADR_BUILDING_F,
                          ADR_OFFICE_F,
                          D,
                          IS_HIGH_PRIOR_RECIEVE,
                          PSP_IS_USE_LIMIT,
                          PR_START_DT,
                          MAX_REPORT_ROW,
                          PER_MONTH,
                          PER_YEAR,
                          OPFU_NAME,
                          ORG_CODE,
                          PR_TP,
                          MAX (PRS_ID)      AS PRS_ID,
                          SUM (PRS_SUM)     PRS_SUM,
                          COUNT (1)         AS x_cnt
                     FROM (SELECT DISTINCT
                                  prs_id,
                                  s.prs_num,
                                  0
                                      pp_pn,
                                  prs_sum,
                                  p.com_org
                                      AS org_id,
                                  /*s.prs_pc_num */
                                  CASE
                                      WHEN TRIM (
                                               REPLACE (
                                                   SUBSTR (
                                                       prs_pc_num,
                                                       1,
                                                       LENGTH (prs_pc_num) - 9),
                                                   '0',
                                                   ' '))
                                               IS NULL
                                      THEN
                                          SUBSTR (prs_pc_num, -9)
                                      WHEN prs_pc_num LIKE p.com_org || '-%'
                                      THEN
                                          SUBSTR (prs_pc_num,
                                                  6 - LENGTH (prs_pc_num))
                                      ELSE
                                          prs_pc_num
                                  END
                                      AS prs_pc_num,
                                  s.prs_inn,
                                  s.prs_doc_num
                                      AS prs_pasp,
                                  prs_pc,
                                  s.prs_apartment
                                      AS adr_office,
                                  s.prs_block,
                                  s.prs_building
                                      AS adr_building, --adr.adr_office, adr.adr_building,
                                  kt.kaot_full_name
                                      AS stlm_name,
                                  ---nst.nsrt_name||' '||ns.ns_name
                                  NVL (
                                      TRIM (nst.nsrt_name || ' ' || ns.ns_name),
                                      prs_street)
                                      AS ul_name, --stlm_name, ul_name, ind_lim_value, -- 20220720 adr.adr_corpus, adr.adr_ul, ul_stlm, ul_id, ind_id,
                                  s.prs_pay_dt
                                      AS pp_date,
                                  UPPER (
                                      TRIM (
                                          CONCAT (
                                                 TRIM (
                                                     CONCAT (
                                                         TRIM (s.prs_ln) || ' ',
                                                         TRIM (s.prs_fn)))
                                              || ' ',
                                              TRIM (s.prs_mn))))
                                      prs_pib,
                                  NVL (prs_index, '00000')
                                      AS prs_index,
                                  --#86654 upper(coalesce(cn.ncn_sname,' '))
                                  ''
                                      AS ncn_name,
                                  s.prs_address
                                      AS address,
                                  /*case nvl(adr_pp_tp,'D') when 'D' then RDM$ADDRESS_POST.dlvr_info(pnf_id, 'DD') else null end*/
                                  /*nd_code*/
                                  NVL (d.nd_code, x.pdm_nd_num)
                                      AS dlvr_code_f,
                                  CASE
                                      WHEN                         /*nd_code*/
                                           NVL (d.nd_code, x.pdm_nd_num)
                                               IS NOT NULL
                                      THEN
                                          0
                                      ELSE
                                          1
                                  END
                                      is_payed_on_post,             -- DD ????
                                     REGEXP_REPLACE (s.prs_building, '\D', ',')
                                  || ','
                                      adr_building_f,
                                     REGEXP_REPLACE (s.prs_apartment,
                                                     '\D',
                                                     ',')
                                  || ','
                                      adr_office_f,
                                  -- ppp_poa_show_dt = Дата підтвердження дії довіреності
                                  ' '
                                      d,
                                  ''
                                      is_high_prior_recieve,          --- ????
                                  ''
                                      psp_is_use_limit,               --- ????
                                  pr_start_dt,                     -- per_date
                                  -- MAX_REPORT_ROW_B1M  Максимальна кількість рядків у відомості на виплату, форма B-1M  26  rpt_payroll.BuildPaymentB1M
                                  20
                                      max_report_row,
                                  UPPER (
                                      TO_CHAR (pr_start_dt,
                                               'month',
                                               'nls_date_language = UKRAINIAN'))
                                      per_month,
                                  EXTRACT (YEAR FROM pr_start_dt)
                                      per_year,
                                  UPPER (NVL (dpp.dpp_sname, org_name))
                                      opfu_name, --  #89720 Виправити назву УСЗН
                                  TO_CHAR (org_code)
                                      org_code,
                                  DECODE (                   /*ptp.dic_value*/
                                          pr_tp,  'M', '1',  'A', '2')
                                      pr_tp
                             FROM payroll p
                                  JOIN pr_sheet s ON prs_pr = pr_id
                                  JOIN v_opfu op ON op.org_id = p.com_org
                                  LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                                      ON     dpp.dpp_org = op.org_id
                                         AND dpp.dpp_tp = 'OSZN'
                                         AND dpp.history_status = 'A' --  #89720
                                  -- #86654 left join uss_ndi.v_ndi_post_office pi on pi.npo_index = /*s.prs_index*/lpad(s.prs_index, 5, '0') and pi.history_status = 'A'
                                  --   #85038  npo_org не заповнене  and pi.npo_org = p.com_org
                                  -- #86654 left join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A' -- #83697  + 2 left
                                  LEFT JOIN uss_ndi.v_ndi_katottg kt
                                      ON kt.kaot_id = s.prs_kaot
                                  LEFT JOIN uss_ndi.v_ndi_street ns
                                      ON ns.ns_id = s.prs_ns -- #87729 io додав left
                                  LEFT JOIN uss_ndi.v_ndi_street_type nst
                                      ON nst.nsrt_id = ns.ns_nsrt
                                  LEFT JOIN uss_ndi.v_ndi_delivery d
                                      ON nd_id = prs_nd
                                  -- io 20221226 Якщо в ВВ на пошту не вказано ід ДД  (prs_nd), беремо код ДД з pdm_nd_num   (№ доставочної дільниці з асопд )
                                  /* #86973  дублі  join pc_account a on  pa_id = prs_pa
                                      join pc_decision pd on  prs_pc=pd_pc and pd_nst = pa_nst
                                      join pd_pay_method pdm on pd_id= pdm_pd and pdm.history_status = 'A' AND pdm_is_actual = 'T'*/
                                  LEFT JOIN
                                  (                                  -- #86973
                                   SELECT ps.prs_id                           AS x_prs,
                                          pdm.pdm_nd_num,
                                          ROW_NUMBER ()
                                              OVER (
                                                  PARTITION BY ps.prs_pc
                                                  ORDER BY
                                                      DECODE (pd_st, 'S', 1, 0) DESC,
                                                      pd.pd_start_dt DESC)    AS x_rn
                                     FROM pr_sheet ps
                                          JOIN pc_account a
                                              ON pa_id = ps.prs_pa
                                          JOIN pc_decision pd
                                              ON     ps.prs_pc = pd_pc
                                                 AND pd_nst = pa_nst
                                          JOIN pd_pay_method pdm
                                              ON     pd_id = pdm_pd
                                                 AND pdm.history_status = 'A'
                                                 AND pdm_is_actual = 'T'
                                                 AND pdm.pdm_pay_tp = 'POST'
                                    WHERE ps.prs_pr = p_pr_id) x
                                      ON prs_id = x_prs AND x_rn = 1
                            WHERE     pr_id = p_pr_id
                                  AND pr_pay_tp = 'POST'
                                  AND prs_sum                           /*!=*/
                                              > 0
                                  AND prs_st NOT IN ('PP')
                                  AND prs_tp IN ('PP') -- #85724 -- Виплата поштою
                                                      ) x1
                 GROUP BY PRS_NUM,
                          PP_PN,
                          ORG_ID,
                          PRS_PC_NUM,
                          PRS_INN,
                          PRS_PASP,
                          PRS_PC,
                          ADR_OFFICE,
                          PRS_BLOCK,
                          ADR_BUILDING,
                          STLM_NAME,
                          UL_NAME,
                          PP_DATE,
                          PRS_PIB,
                          PRS_INDEX,
                          NCN_NAME,
                          ADDRESS,
                          DLVR_CODE_F,
                          IS_PAYED_ON_POST,
                          ADR_BUILDING_F,
                          ADR_OFFICE_F,
                          D,
                          IS_HIGH_PRIOR_RECIEVE,
                          PSP_IS_USE_LIMIT,
                          PR_START_DT,
                          MAX_REPORT_ROW,
                          PER_MONTH,
                          PER_YEAR,
                          OPFU_NAME,
                          ORG_CODE,
                          PR_TP),
            t2
            AS
                (SELECT ROW_NUMBER ()
                            OVER (
                                ORDER BY
                                    org_id,
                                    prs_index,
                                    pp_date,
                                    is_payed_on_post,
                                    dlvr_code_f,
                                    CASE is_payed_on_post
                                        WHEN 1 THEN prs_pib
                                    END,
                                    stlm_name,
                                    ul_name,
                                    TO_NUMBER (
                                        REPLACE (
                                            SUBSTR (
                                                adr_building_f,
                                                1,
                                                INSTR (adr_building_f, ',')),
                                            ',',
                                            '')),
                                    TO_NUMBER (
                                        REPLACE (
                                            SUBSTR (
                                                adr_building_f,
                                                INSTR (adr_building_f, ','),
                                                LENGTH (adr_building_f)),
                                            ',',
                                            '')) NULLS FIRST,
                                    SUBSTR (adr_building,
                                            INSTR (adr_building_f, ','),
                                            LENGTH (adr_building_f)),
                                    TO_NUMBER (
                                        REPLACE (
                                            SUBSTR (
                                                adr_office_f,
                                                1,
                                                INSTR (adr_office_f, ',')),
                                            ',',
                                            '')),
                                    TO_NUMBER (
                                        REPLACE (
                                            SUBSTR (
                                                adr_office_f,
                                                INSTR (adr_office_f, ','),
                                                LENGTH (adr_office_f)),
                                            ',',
                                            '')) NULLS FIRST,
                                    SUBSTR (adr_office,
                                            INSTR (adr_office_f, ','),
                                            LENGTH (adr_office_f)))
                            rn,
                        prs_id,
                        prs_num,
                        pp_pn,
                        pp_date,
                        prs_sum,
                        org_id,
                        ---substr(to_char(prs_pc_num),-6,6) prs_pc_num,
                        prs_pc_num,
                        prs_inn,
                        prs_pib,
                        prs_index,
                        ncn_name,
                        address,
                        /*dlvr_code,*/
                        dlvr_code_f
                            dlvr_code,
                        is_payed_on_post,
                        prs_pasp,
                        stlm_name,
                        ul_name,
                        999999999
                            ind_lim_value,
                        d,
                        is_high_prior_recieve,
                        psp_is_use_limit,
                        max_report_row,
                        per_month,
                        per_year,
                        opfu_name,
                        org_code,
                        pr_tp
                   FROM t1 pnf),
            t
            AS
                (SELECT prs_index,
                        dlvr_code,
                        is_payed_on_post,
                        pp_date,
                        ind_lim_value,
                        prs_sum,
                        org_id,
                        rn,
                        prs_pib,
                        ncn_name,
                        address,
                        prs_pasp,
                        prs_id,
                        prs_num,
                        pp_pn,
                        prs_pc_num,
                        prs_inn,
                        ROW_NUMBER ()
                            OVER (PARTITION BY org_id,
                                               prs_index,
                                               pp_date,
                                               is_payed_on_post,
                                               dlvr_code
                                  ORDER BY rn)
                            rn_rollup,
                        -- накопительный итог по сумме для распределения по лимитам
                        SUM (prs_sum)
                            OVER (PARTITION BY org_id,
                                               prs_index,
                                               pp_date,
                                               is_payed_on_post,
                                               dlvr_code
                                  ORDER BY rn ASC
                                  RANGE UNBOUNDED PRECEDING)
                            prs_sum_rollup,
                        d,
                        is_high_prior_recieve,
                        psp_is_use_limit,
                        max_report_row,
                        per_month,
                        per_year,
                        opfu_name,
                        org_code,
                        pr_tp
                   FROM t2)
          SELECT prs_id,
                 pp_date,
                 prs_sum,
                 org_id,
                 prs_pc_num,
                 prs_inn,
                 prs_pib,
                 prs_index,
                 ncn_name,
                 address,
                 dlvr_code,
                 is_payed_on_post,
                 prs_pasp,
                 ind_lim_value,
                 prs_num,      -- у нас нумерація уже задана при формуванні ВВ
                 ROW_NUMBER ()
                     OVER (
                         PARTITION BY prs_index,
                                      CASE
                                          WHEN is_payed_on_post = 0
                                          THEN
                                              dlvr_code
                                          ELSE
                                              NULL
                                      END,
                                      prs_num
                         ORDER BY rn)                    AS pp_pn,
                 d,
                 is_high_prior_recieve,
                 TO_CHAR (EXTRACT (DAY FROM pp_date))    pp_day,
                 per_month,
                 per_year,
                 opfu_name,
                 org_code,
                 pr_tp
            FROM t
        ORDER BY org_id,
                 prs_index,
                 prs_num,
                 pp_pn,
                 --rn_rollup,RDM$ADDRESS_POST.get_rn_rollup(rn_rollup, prs_sum, ind_lim_value, max_report_row, psp_is_use_limit),
                 rn;

    FUNCTION get_acc_setup_pib (p_mode       IN NUMBER,
                                p_pib_mode   IN NUMBER DEFAULT 1,
                                p_org        IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION get_idcode (p_idcode IN VARCHAR2)
        RETURN VARCHAR2;

    -- Скорочення назви органу
    FUNCTION get_org_sname (p_org_name VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION PrintRight (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2;

    FUNCTION PrintLeft (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2;

    FUNCTION str2tbl (p_str    VARCHAR2,
                      p_pars   VARCHAR2 DEFAULT ',',
                      pRpad    SMALLINT DEFAULT 0)
        RETURN T_ARRVAR;

    -- місяць в родовому відмінку
    FUNCTION get_mnth_pad_name (p_mnth IN NUMBER)
        RETURN VARCHAR2;

    --- відомості на виплату, форма B-1M
    PROCEDURE BuildPaymentB1M (p_pr_id   IN            payroll.pr_id%TYPE,
                               ---p_org_id in payroll.com_org%type,
                               p_rpt     IN OUT NOCOPY BLOB);

    PROCEDURE BuildPaymentB4M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd  in v_asopd2opfu.asop_org%type,
                               p_rpt     IN OUT NOCOPY BLOB);


    PROCEDURE BuildPaymentB5M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd  in v_asopd2opfu.asop_org%type,
                               p_rpt     IN OUT NOCOPY BLOB);


    PROCEDURE BuildPaymentB6M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd in psp2org.com_org%type,
                               p_rpt     IN OUT NOCOPY BLOB);

    PROCEDURE BuildPaymentV02M19_Supr (
        p_pr_id   IN            payroll.pr_id%TYPE,
        -- p_org_id in psp2org.com_org%type,
        -- p_asopd  in v_asopd2opfu.asop_org%type,
        p_rpt     IN OUT NOCOPY BLOB);

    -- ora 01775 :  v_opfu_all, ppvp_common

    -- Формуємо архів з файлами друкованих форм по ВВ
    PROCEDURE BuildPostFile (p_pr_list    IN            VARCHAR2,
                             p_rpt        IN OUT NOCOPY BLOB,
                             p_rpt_name      OUT        VARCHAR2);


    -------------  BANK  ------------------------
    -- Список 1/2 -  SP ZA OR / ZA VKLAD
    FUNCTION BuildSpis2 (p_pr_id       payroll.pr_id%TYPE,
                         p_prs_tp      pr_sheet.prs_tp%TYPE,
                         p_prs_nb      pr_sheet.prs_nb%TYPE:= NULL,
                         p_prs_num     pr_sheet.prs_num%TYPE:= 0,
                         p_mode        NUMBER:= 0,
                         p_format      INT:= 14,
                         p_show_migr   VARCHAR2:= 'F',
                         p_rows_cnt    INT:= 0)                       --#86557
        RETURN BLOB;

    --  ОПИС СПИСКIВ -- V 0 2 M 2 3
    FUNCTION BuildOpis2 (p_pr_id      payroll.pr_id%TYPE,
                         p_prs_tp     pr_sheet.prs_tp%TYPE,
                         p_prs_nb     pr_sheet.prs_nb%TYPE:= NULL,
                         p_prs_num    pr_sheet.prs_num%TYPE:= 0,
                         p_format     INT:= 14,
                         p_rows_cnt   INT:= 0)                        --#86557
        RETURN BLOB;

    -- СУПРОВIДНА  ВIДОМIСТЬ НА ЗАРАХУВАННЯ   V 0 2 M 2 0
    FUNCTION BuildAccompSheet (
        p_pr_id      payroll.pr_id%TYPE,
        p_prs_tp     pr_sheet.prs_tp%TYPE,
        p_prs_nb     pr_sheet.prs_nb%TYPE:= NULL,
        p_prs_num    pr_sheet.prs_num%TYPE:= 0,
        p_format     INT:= 14,
        p_nb_num     uss_ndi.v_ndi_bank.nb_num%TYPE:= NULL,
        p_nb_mfo     uss_ndi.v_ndi_bank.nb_mfo%TYPE:= NULL,
        p_rows_cnt   INT:= 0)                                         --#86557
        RETURN BLOB;

    -- #86403 підготовка даних з розрахунком коду філії/відділення
    PROCEDURE prepare_bank_data (p_pr_id       payroll.pr_id%TYPE,
                                 p_prs_tp      pr_sheet.prs_tp%TYPE,
                                 p_prs_nb      pr_sheet.prs_nb%TYPE:= NULL,
                                 p_prs_num     pr_sheet.prs_num%TYPE:= 0,
                                 p_mode        NUMBER:= 0,
                                 p_show_migr   VARCHAR2:= 'F');

    -- Формуємо архів з файлами друкованих форм на банк по ВВ
    PROCEDURE BuildBankFile (p_pr_ids     IN            VARCHAR2,
                             --    p_rows_cnt   int := 0, --#86557
                             p_rpt        IN OUT NOCOPY BLOB,
                             p_rpt_name      OUT        VARCHAR2);

    ---------------------------------------------------------------------------------------------
    -----  Відрахування #90095 Додати друковані форми на матричний принтер по відрахуванням -----
    ---------------------------------------------------------------------------------------------
    --  1. Список по відрахуванням
    PROCEDURE BuildAccrualList_R2 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        p_rpt      IN OUT NOCOPY BLOB);

    --  4. Список по держутриманням (перерахованих)
    PROCEDURE BuildAccrualList_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        p_rpt      IN OUT NOCOPY BLOB);

    -- РЕЄСТР №  **** вiдрахувань з допомог
    PROCEDURE BuildDeduction_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        p_rpt      IN OUT NOCOPY BLOB);

    -- СУПРОВIДНА ВIДОМIСТЬ
    PROCEDURE BuildSuprovid_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        p_rpt      IN OUT NOCOPY BLOB);

    -- Формуємо архів з файлами друкованих форм по відрахуваннях/утриманнях
    -- p_prs_tp = 'ABU' /  'AUU'  ----  Відрахування банком (ю.особа) /  Утримання (ю.особа)
    PROCEDURE BuildAccrualFile (p_pr_list    IN            VARCHAR2,
                                p_prs_tp     IN            VARCHAR2,
                                p_rpt        IN OUT NOCOPY BLOB,
                                p_rpt_name      OUT        VARCHAR2);
END DNET$RPT_MATRIX;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_MATRIX TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_MATRIX TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_MATRIX
IS
    CT_ASCII_FF             CHAR (2) := CHR (12); /* io 20230504 OZ: просють для матричних в кінці документу вставити символ переводу сторінки, щоб новий документ друкувався з нової сторінки '';*/
                                                  -- символ прогона страницы FF (для матричных принтеров)
    CT_MAX_REPORT_ROW_TXT   NUMBER := 72; -- внести в таблицю системних параметрів
    -- prm_utl.GetParamAsNumber('MAX_REPORT_ROW_TXT', sysdate); -- Максимальна кількість рядків у текстових відомостях

    c_per_start             VARCHAR2 (2) := '04';
    c_per_stop              VARCHAR2 (2) := '25';

    exNoData                EXCEPTION;

    -- #97222 Переробити функцію визначення підписантів для відомостей на матричному принтері
    --  io 20240117 тимчасово, до установки глобального патча на пром
    -- ПІБ з налаштувань облікової політики
    -- p_mode = 0 - керівника з облікової політики
    -- p_mode = 1 - особу, що затверджує з облікової політики
    -- p_org  - com_org для якого потрібно визначити ПІБ  #97222 io 20240117
    FUNCTION get_acc_setup_pib (p_mode       IN NUMBER,
                                p_pib_mode   IN NUMBER DEFAULT 1,
                                p_org        IN NUMBER DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_pib         VARCHAR2 (1000);
        l_org         NUMBER := 51807;         --nvl(p_org, tools.getcurrorg);
        l_field       VARCHAR2 (50)
            := CASE
                   WHEN p_mode = 0 THEN 'acs_Fnc_Signer'
                   WHEN p_mode = 1 THEN 'acs_Fnc_Bt_Allow'
               END;
        l_pib_field   VARCHAR2 (500)
            := CASE
                   WHEN p_pib_mode = 0
                   THEN
                       'f.fnc_ln || '' '' || f.fnc_fn || '' '' || f.fnc_mn '
                   WHEN p_pib_mode = 1
                   THEN
                       'f.fnc_ln || '' '' || substr(f.fnc_fn, 1, 1) || ''. '' || substr(f.fnc_mn, 1, 1) || ''.'' '
               END;
    BEGIN
        EXECUTE IMMEDIATE '
    SELECT max(' || l_pib_field || ')
      FROM uss_ndi.v_ndi_acc_setup t
      JOIN uss_ndi.v_ndi_functionary f ON (f.fnc_id = t.' || l_field || ')
     WHERE t.com_org = :1
    '
            INTO l_pib
            USING l_org;

        --    raise_application_error(-20000,'p_mode='||p_mode||',p_pib_mode='||p_pib_mode||',l_org='||l_org||'==>>'||l_pib);
        RETURN l_Pib;
    END;

    PROCEDURE add_CT_ASCII_FF (p_rpt IN OUT NOCOPY BLOB)
    IS
    BEGIN
        DBMS_LOB.writeappend (
            p_rpt,
            DBMS_LOB.getlength (UTL_RAW.cast_to_raw (CT_ASCII_FF)),
            UTL_RAW.cast_to_raw (CT_ASCII_FF));
    END;

    FUNCTION get_idcode (p_idcode IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN (CASE
                    WHEN     LENGTH (p_idcode) = 10
                         AND TRANSLATE (p_idcode, '_0123456789', '_') IS NULL
                    THEN
                        p_idcode
                    ELSE
                        '0000000000'
                END);
    END;

    -- функция отрезает 'Управління ПФУ в/у' и остаток переводит в родительний падеж
    FUNCTION TransformOrgName (p_org_name v_opfu.org_name%TYPE)
        RETURN VARCHAR2
    IS
        v_org_name   v_opfu.org_name%TYPE;
    BEGIN
        v_org_name := p_org_name;
        v_org_name :=
               REPLACE (
                   REPLACE (
                       REPLACE (
                           REPLACE (v_org_name, 'Управління ПФУ в ', ''),
                           'Управлiння ПФУ у ',
                           ''),
                       'Управління ПФУ у',
                       ''),
                   'ому районі',
                   'ого района')
            || ' ';

        IF (INSTR (v_org_name, 'м.') = 1)
        THEN
            v_org_name :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (REPLACE (v_org_name, 'ьку ', 'ькa '),
                                     'вцi ',
                                     'вки '),
                            'лi ',
                            'ля '),
                        'i ',
                        'а '),
                    'областа',
                    'області');
        END IF;

        RETURN v_org_name;
    END;

    -- Скорочення назви органу
    FUNCTION get_org_sname (p_org_name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_sname   VARCHAR2 (4000);
    BEGIN
        l_sname :=
            REPLACE (
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                REPLACE (
                                                    REPLACE (
                                                        REPLACE (
                                                            REPLACE (
                                                                REPLACE (
                                                                    REPLACE (
                                                                        REPLACE (
                                                                            REPLACE (
                                                                                REPLACE (
                                                                                    REPLACE (
                                                                                        REPLACE (
                                                                                            REPLACE (
                                                                                                UPPER (
                                                                                                    REPLACE (
                                                                                                        p_org_name,
                                                                                                        '  ',
                                                                                                        ' ')),
                                                                                                'СТРУКТУРНИЙ ПІДРОЗДІЛ ВИКОНАВЧОГО ОРГАНУ ',
                                                                                                'СПВО '),
                                                                                            'ОБЛАСНОЇ ДЕРЖАВНОЇ АДМІНІСТРАЦІЇ ',
                                                                                            'ОДА '),
                                                                                        'УПРАВЛІННЯ СОЦІАЛЬНОГО РОЗВИТКУ ',
                                                                                        'УСР '),
                                                                                    'ДЕПАРТАМЕНТ СОЦПОЛІТИКИ ',
                                                                                    'ДСП '),
                                                                                'УПРАВЛІННЯ СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                                'УСП '),
                                                                            'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ТА МОЛОДІЖНОЇ ПОЛІТИКИ ',
                                                                            'ДСМП '),
                                                                        'ДЕПАРТАМЕНТ ПРАЦІ ТА СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                        'ДПСП '),
                                                                    'ОБЛАСНИЙ ЦЕНТР ПО НАРАХУВАННЮ ТА ЗДІЙСНЕННЮ СОЦІАЛЬНИХ ВИПЛАТ',
                                                                    'ОЦНЗСВ'),
                                                                'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ПОЛІТИКИ ',
                                                                'ДСП '),
                                                            'ДЕПАРТАМЕНТ СОЦІАЛЬНОЇ ТА СІМЕЙНОЇ ПОЛІТИКИ ',
                                                            'ДССП '),
                                                        'ДЕПАРТАМЕНТ ПРАЦІ ТА СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                                                        'ДПСЗН '),
                                                    'ВИКОНАВЧОГО КОМІТЕТУ ',
                                                    'ВК '),
                                                'ОБ''ЄДНАНА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                                'ОТГ'),
                                            'СЕЛИЩНА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                            'СТГ'),
                                        'МІСЬКА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                        'МТГ'),
                                    'СІЛЬСЬКА ТЕРИТОРІАЛЬНА ГРОМАДА',
                                    'СТГ'),
                                'УПРАВЛІННЯ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                                'УСЗН '),
                            'УПРАВЛІННЯ СОЦІАЛЬНОГО ЗАХИСТУ ',
                            'УСЗ '),
                        'ДЕПАРТАМЕНТ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ТА ПИТАНЬ АТО ',
                        'ДСЗН ТА ПАТО '),
                    'ДЕПАРТАМЕНТ СОЦІАЛЬНОГО ЗАХИСТУ НАСЕЛЕННЯ ',
                    'ДСЗН '),
                ' МІСЬКОЇ РАДИ',
                ' МР');
        RETURN l_sname;
    END;


    FUNCTION SUM_TO_TEXT (v_sum        NUMBER,
                          v_cur_id                /*nsi_currency.cur_id%type*/
                                       NUMBER DEFAULT 1, -- 1 - UAH, 2 - USD, 3 - EUR
                          v_mode_kop   SMALLINT DEFAULT 1, -- 1 - грн и копейки сокращенно, 2 - грн и копейки полностью
                          v_lang       SMALLINT DEFAULT 1 -- 1 - украинский, 2 - русский
                                                         )
        RETURN VARCHAR2
    IS
        -- Сумма прописью
        -- +27.01.2003
        -- Garder
        -- +07.06.2016 дополнил ikulish
        TYPE mass IS TABLE OF VARCHAR2 (20)
            INDEX BY BINARY_INTEGER;

        TYPE rec IS RECORD
        (
            a    VARCHAR2 (15),
            b    VARCHAR2 (15),
            c    VARCHAR2 (15),
            d    VARCHAR2 (15),
            e    VARCHAR2 (15)
        );

        TYPE razr IS TABLE OF rec
            INDEX BY BINARY_INTEGER;

        m1      mass;
        m1a     mass;
        m11     mass;
        m10     mass;
        m100    mass;
        r       razr;
        c       VARCHAR2 (255);
        n       NUMBER;
        i       NUMBER;
        again   BOOLEAN;
    BEGIN
        --**********************************  Заполняем массивы данными
        IF v_lang = 1
        THEN
            -- массив 1 разряда (разряды с конца)
            m1 (0) := '';
            m1 (1) := 'одна ';
            m1 (2) := 'дві ';
            m1 (3) := 'три ';
            m1 (4) := 'чотири ';
            m1 (5) := 'п''ять ';
            m1 (6) := 'шість ';
            m1 (7) := 'сім ';
            m1 (8) := 'вісім ';
            m1 (9) := 'дев''ять ';
            -- массив 1 разряда для тысяч
            m1a (0) := '';
            m1a (1) := 'один ';
            m1a (2) := 'два ';
            m1a (3) := 'три ';
            m1a (4) := 'чотири ';
            m1a (5) := 'п''ять ';
            m1a (6) := 'шість ';
            m1a (7) := 'сім ';
            m1a (8) := 'вісім ';
            m1a (9) := 'дев''ять ';
            -- массив 1 и 2 разрядов для чисел от 11 до 19
            m11 (0) := '';
            m11 (1) := 'одинадцять ';
            m11 (2) := 'дванадцять ';
            m11 (3) := 'тринадцять ';
            m11 (4) := 'чотирнадцять ';
            m11 (5) := 'п''ятнадцять ';
            m11 (6) := 'шістнадцять ';
            m11 (7) := 'сімнадцять ';
            m11 (8) := 'вісімнадцять ';
            m11 (9) := 'дев''ятнадцять ';
            -- массив 2 разряда
            m10 (0) := '';
            m10 (1) := 'десять ';
            m10 (2) := 'двадцять ';
            m10 (3) := 'тридцять ';
            m10 (4) := 'сорок ';
            m10 (5) := 'п''ятдесят ';
            m10 (6) := 'шістдесят ';
            m10 (7) := 'сімдесят ';
            m10 (8) := 'вісімдесят ';
            m10 (9) := 'дев''яносто ';
            -- массив 3 разряда
            m100 (0) := '';
            m100 (1) := 'сто ';
            m100 (2) := 'двісті ';
            m100 (3) := 'триста ';
            m100 (4) := 'чотириста ';
            m100 (5) := 'п''ятсот ';
            m100 (6) := 'шістсот ';
            m100 (7) := 'сімсот ';
            m100 (8) := 'вісімсот ';
            m100 (9) := 'дев''ятсот ';

            IF v_mode_kop = 1
            THEN
                IF v_cur_id = 1
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'грн. ';
                    r (1).a := 'грн. ';
                    r (2).a := 'грн. ';
                    r (3).a := 'грн. ';
                    r (4).a := 'грн. ';
                    r (5).a := 'грн. ';
                    r (6).a := 'грн. ';
                    r (7).a := 'грн. ';
                    r (8).a := 'грн. ';
                    r (9).a := 'грн. ';
                ELSIF v_cur_id = 2
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'дол. ';
                    r (1).a := 'дол. ';
                    r (2).a := 'дол. ';
                    r (3).a := 'дол. ';
                    r (4).a := 'дол. ';
                    r (5).a := 'дол. ';
                    r (6).a := 'дол. ';
                    r (7).a := 'дол. ';
                    r (8).a := 'дол. ';
                    r (9).a := 'дол. ';
                ELSIF v_cur_id = 3
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'євро ';
                    r (1).a := 'євро ';
                    r (2).a := 'євро ';
                    r (3).a := 'євро ';
                    r (4).a := 'євро ';
                    r (5).a := 'євро ';
                    r (6).a := 'євро ';
                    r (7).a := 'євро ';
                    r (8).a := 'євро ';
                    r (9).a := 'євро ';
                END IF;
            ELSIF v_mode_kop = 2
            THEN
                IF v_cur_id = 1
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'гривень ';
                    r (1).a := 'гривня ';
                    r (2).a := 'гривні ';
                    r (3).a := 'гривні ';
                    r (4).a := 'гривні ';
                    r (5).a := 'гривень ';
                    r (6).a := 'гривень ';
                    r (7).a := 'гривень ';
                    r (8).a := 'гривень ';
                    r (9).a := 'гривень ';
                ELSIF v_cur_id = 2
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'доларів США ';
                    r (1).a := 'долар США ';
                    r (2).a := 'долара США ';
                    r (3).a := 'долара США ';
                    r (4).a := 'долара США ';
                    r (5).a := 'доларів США ';
                    r (6).a := 'доларів США ';
                    r (7).a := 'доларів США ';
                    r (8).a := 'доларів США ';
                    r (9).a := 'доларів США ';
                ELSIF v_cur_id = 3
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'євро ';
                    r (1).a := 'євро ';
                    r (2).a := 'євро ';
                    r (3).a := 'євро ';
                    r (4).a := 'євро ';
                    r (5).a := 'євро ';
                    r (6).a := 'євро ';
                    r (7).a := 'євро ';
                    r (8).a := 'євро ';
                    r (9).a := 'євро ';
                END IF;
            END IF;

            -- массив перед 4 разрядом
            r (0).b := 'тисяч ';
            r (1).b := 'тисяча ';
            r (2).b := 'тисячі ';
            r (3).b := 'тисячі ';
            r (4).b := 'тисячі ';
            r (5).b := 'тисяч ';
            r (6).b := 'тисяч ';
            r (7).b := 'тисяч ';
            r (8).b := 'тисяч ';
            r (9).b := 'тисяч ';
            -- массив перед 7 разрядом
            r (0).c := 'мільйонів ';
            r (1).c := 'мільйон ';
            r (2).c := 'мільйони ';
            r (3).c := 'мільйони ';
            r (4).c := 'мільйони ';
            r (5).c := 'мільйонів ';
            r (6).c := 'мільйонів ';
            r (7).c := 'мільйонів ';
            r (8).c := 'мільйонів ';
            r (9).c := 'мільйонів ';
            -- массив перед 10 разрядом
            r (0).d := 'мільярдів ';
            r (1).d := 'мільярд ';
            r (2).d := 'мільярди ';
            r (3).d := 'мільярди ';
            r (4).d := 'мільярди ';
            r (5).d := 'мільярдів ';
            r (6).d := 'мільярдів ';
            r (7).d := 'мільярдів ';
            r (8).d := 'мільярдів ';
            r (9).d := 'мільярдів ';
        ELSIF v_lang = 2
        THEN
            -- массив 1 разряда (разряды с конца)
            m1 (0) := '';
            m1 (1) := 'одна ';
            m1 (2) := 'две ';
            m1 (3) := 'три ';
            m1 (4) := 'четыре ';
            m1 (5) := 'пять ';
            m1 (6) := 'шесть ';
            m1 (7) := 'семь ';
            m1 (8) := 'восемь ';
            m1 (9) := 'девять ';
            -- массив 1 разряда для тысяч
            m1a (0) := '';
            m1a (1) := 'один ';
            m1a (2) := 'два ';
            m1a (3) := 'три ';
            m1a (4) := 'четыре ';
            m1a (5) := 'пять ';
            m1a (6) := 'шесть ';
            m1a (7) := 'семь ';
            m1a (8) := 'восемь ';
            m1a (9) := 'девять ';
            -- массив 1 и 2 разрядов для чисел от 11 до 19
            m11 (0) := '';
            m11 (1) := 'одиннадцать ';
            m11 (2) := 'двенадцать ';
            m11 (3) := 'тринадцать ';
            m11 (4) := 'четырнадцать ';
            m11 (5) := 'пятнадцать ';
            m11 (6) := 'шестнадцать ';
            m11 (7) := 'семнадцать ';
            m11 (8) := 'восемнадцать ';
            m11 (9) := 'девятнадцать ';
            -- массив 2 разряда
            m10 (0) := '';
            m10 (1) := 'десять ';
            m10 (2) := 'двадцать ';
            m10 (3) := 'тридцать ';
            m10 (4) := 'сорок ';
            m10 (5) := 'пятьдесят ';
            m10 (6) := 'шестьдесят ';
            m10 (7) := 'семьдесят ';
            m10 (8) := 'восемьдесят ';
            m10 (9) := 'девяносто ';
            -- массив 3 разряда
            m100 (0) := '';
            m100 (1) := 'сто ';
            m100 (2) := 'двести ';
            m100 (3) := 'триста ';
            m100 (4) := 'четыреста ';
            m100 (5) := 'пятьсот ';
            m100 (6) := 'шестьсот ';
            m100 (7) := 'семьсот ';
            m100 (8) := 'восемьсот ';
            m100 (9) := 'девятьсот ';

            IF v_mode_kop = 1
            THEN
                IF v_cur_id = 1
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'грн. ';
                    r (1).a := 'грн. ';
                    r (2).a := 'грн. ';
                    r (3).a := 'грн. ';
                    r (4).a := 'грн. ';
                    r (5).a := 'грн. ';
                    r (6).a := 'грн. ';
                    r (7).a := 'грн. ';
                    r (8).a := 'грн. ';
                    r (9).a := 'грн. ';
                ELSIF v_cur_id = 2
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'дол. ';
                    r (1).a := 'дол. ';
                    r (2).a := 'дол. ';
                    r (3).a := 'дол. ';
                    r (4).a := 'дол. ';
                    r (5).a := 'дол. ';
                    r (6).a := 'дол. ';
                    r (7).a := 'дол. ';
                    r (8).a := 'дол. ';
                    r (9).a := 'дол. ';
                ELSIF v_cur_id = 3
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'евро ';
                    r (1).a := 'евро ';
                    r (2).a := 'евро ';
                    r (3).a := 'евро ';
                    r (4).a := 'евро ';
                    r (5).a := 'евро ';
                    r (6).a := 'евро ';
                    r (7).a := 'евро ';
                    r (8).a := 'евро ';
                    r (9).a := 'евро ';
                END IF;
            ELSIF v_mode_kop = 2
            THEN
                IF v_cur_id = 1
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'гривень ';
                    r (1).a := 'гривня ';
                    r (2).a := 'гривни ';
                    r (3).a := 'гривни ';
                    r (4).a := 'гривни ';
                    r (5).a := 'гривень ';
                    r (6).a := 'гривень ';
                    r (7).a := 'гривень ';
                    r (8).a := 'гривень ';
                    r (9).a := 'гривень ';
                ELSIF v_cur_id = 2
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'долларов США ';
                    r (1).a := 'доллар США ';
                    r (2).a := 'доллара США ';
                    r (3).a := 'доллара США ';
                    r (4).a := 'доллара США ';
                    r (5).a := 'долларов США ';
                    r (6).a := 'долларов США ';
                    r (7).a := 'долларов США ';
                    r (8).a := 'долларов США ';
                    r (9).a := 'долларов США ';
                ELSIF v_cur_id = 3
                THEN
                    -- массив перед 1 разрядом
                    r (0).a := 'евро ';
                    r (1).a := 'евро ';
                    r (2).a := 'евро ';
                    r (3).a := 'евро ';
                    r (4).a := 'евро ';
                    r (5).a := 'евро ';
                    r (6).a := 'евро ';
                    r (7).a := 'евро ';
                    r (8).a := 'евро ';
                    r (9).a := 'евро ';
                END IF;
            END IF;

            -- массив перед 4 разрядом
            r (0).b := 'тысяч ';
            r (1).b := 'тысяча ';
            r (2).b := 'тысячи ';
            r (3).b := 'тысячи ';
            r (4).b := 'тысячи ';
            r (5).b := 'тысяч ';
            r (6).b := 'тысяч ';
            r (7).b := 'тысяч ';
            r (8).b := 'тысяч ';
            r (9).b := 'тысяч ';
            -- массив перед 7 разрядом
            r (0).c := 'миллионов ';
            r (1).c := 'миллион ';
            r (2).c := 'миллиона ';
            r (3).c := 'миллиона ';
            r (4).c := 'миллиона ';
            r (5).c := 'миллионов ';
            r (6).c := 'миллионов ';
            r (7).c := 'миллионов ';
            r (8).c := 'миллионов ';
            r (9).c := 'миллионов ';
            -- массив перед 10 разрядом
            r (0).d := 'миллиардов ';
            r (1).d := 'миллиард ';
            r (2).d := 'миллиарда ';
            r (3).d := 'миллиарда ';
            r (4).d := 'миллиарда ';
            r (5).d := 'миллиардов ';
            r (6).d := 'миллиардов ';
            r (7).d := 'миллиардов ';
            r (8).d := 'миллиардов ';
            r (9).d := 'миллиардов ';
        END IF;

        -- массив перед любым разрядом если он пустой
        r (0).e := '';
        r (1).e := '';
        r (2).e := '';
        r (3).e := '';
        r (4).e := '';
        r (5).e := '';
        r (6).e := '';
        r (7).e := '';
        r (8).e := '';
        r (9).e := '';
        -- *************************************  Печатаем копейки
        n := ABS (ROUND (NVL (v_sum, 0), 2));
        c :=
               SUBSTR (TO_CHAR (n, '999999999999999999.99'),
                       LENGTH (TO_CHAR (n, '999999999999999999.99')) - 1,
                       2)
            || CASE
                   WHEN v_cur_id = 1 THEN ' коп.'
                   WHEN v_cur_id IN (2, 3) THEN ' цент.'
               END;
        -- *************************************  Печатаем сумму
        i := 1;
        again := TRUE;

        WHILE again
        LOOP
            IF FLOOR (MOD (n, 100)) > 10 AND FLOOR (MOD (n, 100)) < 20
            THEN
                c := r (0).a || c;
                c := m11 (FLOOR (MOD (n, 10))) || c;
            ELSE
                c := r (FLOOR (MOD (n, 10))).a || c;

                IF i = 3 OR i = 4
                THEN
                    c := m1a (FLOOR (MOD (n, 10))) || c;
                ELSE
                    c := m1 (FLOOR (MOD (n, 10))) || c;
                END IF;

                c := m10 (FLOOR (MOD (TRUNC (n / 10, 0), 10))) || c;
            END IF;

            c := m100 (FLOOR (MOD (TRUNC (n / 100, 0), 10))) || c;
            n := TRUNC (n / 1000, 0);

            IF n = 0
            THEN
                again := FALSE;
            END IF;

            FOR j IN 0 .. 9
            LOOP
                IF i = 1
                THEN
                    r (j).a := r (j).b;
                END IF;

                IF i = 2
                THEN
                    r (j).a := r (j).c;
                END IF;

                IF i = 3
                THEN
                    r (j).a := r (j).d;
                END IF;

                IF MOD (n, 1000) = 0
                THEN
                    r (j).a := r (j).e;
                END IF;
            END LOOP;

            i := i + 1;
        END LOOP;

        IF FLOOR (ABS (NVL (v_sum, 0))) = 0
        THEN
            IF v_lang = 1
            THEN
                c := 'нуль ' || c;
            ELSIF v_lang = 2
            THEN
                c := 'ноль ' || c;
            END IF;
        END IF;

        IF NVL (v_sum, 0) < 0
        THEN
            IF v_lang = 1
            THEN
                c := 'мінус ' || c;
            ELSIF v_lang = 2
            THEN
                c := 'минус ' || c;
            END IF;
        END IF;

        RETURN (UPPER (SUBSTR (c, 1, 1)) || SUBSTR (c, 2, LENGTH (c) - 1));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'SUM_TO_TEXT Error: ' || SQLERRM,
                                     FALSE);
    END;


    PROCEDURE HtpBlob (p_str VARCHAR2, p_lob IN OUT NOCOPY BLOB)
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

    FUNCTION ReplUKRSmb2Dos (l_value VARCHAR2)
        RETURN VARCHAR2
    IS
        rezult   VARCHAR2 (1000);
    BEGIN
        rezult := REPLACE (REPLACE (l_value, 'І', CHR (73)), 'і', CHR (105));
        RETURN rezult;
    --ppvp_common.ReplUKRSmb2Dos
    /*return
      replace(replace(replace(replace(replace(
      replace(replace(replace(replace(replace(
        l_txt,
        '¦', chr(892)),
        '’', ''''),
        'І', chr(73)),
        'і', chr(105)),
        'Ї', chr(ascii('Є')+5)),
        'ї', chr(ascii('є')+5)),
        'Є', chr(170)),
        'є', chr(186)),
        'Ґ', 'Г'),
        'ґ', 'г');*/
    END ReplUKRSmb2Dos;

    -- Дописывает в блоб строку


    FUNCTION ReplUKRSmb2DosBank (l_txt CLOB, p_convert_symb VARCHAR2:= 'F')
        RETURN CLOB
    IS
    BEGIN
        IF p_convert_symb = 'F'
        THEN
            RETURN l_txt;
        ELSIF p_convert_symb = 'K' --  #78357 Кабінет банку - кодування змінено
        THEN
            RETURN REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (l_txt,
                                                                '¦',
                                                                CHR (892)),
                                                       '’',
                                                       ''''),
                                                   'І',
                                                   CHR (73)),
                                               'і',
                                               CHR (105)),
                                           'Ї',
                                           CHR (ASCII ('Є') + 5)),
                                       'ї',
                                       CHR (ASCII ('є') + 5)),
                                   'Є',
                                   CHR (170)),
                               'є',
                               CHR (186)),
                           'Ґ',
                           'Г'),
                       'ґ',
                       'г');
        ELSE
            RETURN REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   l_txt,
                                                   'І',
                                                   CHR (ASCII ('І') + 239)),
                                               'і',
                                               CHR (ASCII ('і') + 239)),
                                           'Ї',
                                           CHR (ASCII ('Ї') + 1)),
                                       'ї',
                                       CHR (ASCII ('ї') + 248)),
                                   'Є',
                                   CHR (ASCII ('Є') + 5)),
                               'є',
                               CHR (ASCII ('є') + 5)),
                           'Ґ',
                           CHR (ASCII ('Ґ') + 5)),
                       'ґ',
                       CHR (ASCII ('ґ') + 6));
        END IF;
    /*  IF p_convert_symb = 'F'
        THEN RETURN l_txt;
      ELSE return replace(replace(replace(replace(
                  replace(replace(replace(replace(
                    l_txt,
                    'І', chr(Ascii('І')+239)),
                    'і', chr(Ascii('і')+239)),
                    'Ї', chr(Ascii('Ї')+1)),
                    'ї', chr(Ascii('ї')+248)),
                    'Є', chr(Ascii('Є')+5)),
                    'є', chr(Ascii('є')+5)),
                    'Ґ', chr(Ascii('Ґ')+5)),
                    'ґ', chr(Ascii('ґ')+6));
      END IF;*/
    END;

    PROCEDURE WriteToBlob (p_line IN VARCHAR2, p_blob IN OUT NOCOPY BLOB)
    IS
        vchardata     VARCHAR2 (4000);
        vrawdata      RAW (32767);
        vdatalength   BINARY_INTEGER := 32767;
    --t_end_line_symbol varchar2(2) := chr(13) || chr(10);
    BEGIN
        vchardata := TRIM (p_line);                    --|| t_end_line_symbol;
        vrawdata := UTL_RAW.cast_to_raw (vchardata);
        vdatalength := LENGTH (vrawdata) / 2;
        DBMS_LOB.writeappend (p_blob, vdatalength, vrawdata);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'WriteLineToBlob' || ': ' || CHR (10) || SQLERRM);
    END;

    FUNCTION PrintCenter (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
        l_buff   VARCHAR2 (4000);
    BEGIN
        l_buff := p_buff;

        IF p_buff IS NULL
        THEN
            l_buff := ' ';
        END IF;

        RETURN RPAD (
                   LPAD (NVL (l_buff, ' '),
                         FLOOR (p_width / 2 + LENGTH (l_buff) / 2),
                         ' '),
                   p_width,
                   ' ');
    END;

    FUNCTION PrintLeft (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN RPAD (NVL (p_buff, ' '), p_width, ' ');
    END;

    FUNCTION PrintRight (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD (NVL (p_buff, ' '), p_width, ' ');
    END;

    FUNCTION PrintBreak (p_buff VARCHAR2, p_width NUMBER)
        RETURN VARCHAR2
    IS
        res      VARCHAR2 (10000);
        l_buff   VARCHAR2 (10000);
    BEGIN
        l_buff := p_buff;

        WHILE LENGTH (l_buff) > p_width
        LOOP
            res :=
                   res
                || SUBSTR (l_buff,
                           1,
                             INSTR (SUBSTR (l_buff, 1, p_width),
                                    ' ',
                                    -1,
                                    1)
                           - 1)
                || CHR (10)
                || ' ';
            l_buff :=
                SUBSTR (l_buff,
                          INSTR (SUBSTR (l_buff, 1, p_width),
                                 ' ',
                                 -1,
                                 1)
                        + 1);
        END LOOP;

        res := res || l_buff;
        RETURN res;
    END;

    --
    FUNCTION str2tbl (p_str    VARCHAR2,
                      p_pars   VARCHAR2 DEFAULT ',',
                      pRpad    SMALLINT DEFAULT 0)
        RETURN T_ARRVAR
    AS
        l_str    LONG DEFAULT p_str || p_pars;
        l_n      NUMBER;
        l_data   T_ARRVAR := T_ARRVAR ();
    BEGIN
        LOOP
            l_n := INSTR (l_str, p_pars);
            EXIT WHEN (NVL (l_n, 0) = 0);
            l_data.EXTEND;
            l_data (l_data.COUNT) :=
                CASE pRpad
                    WHEN 0 THEN LTRIM (RTRIM (SUBSTR (l_str, 1, l_n - 1)))
                    ELSE RPAD (SUBSTR (l_str, 1, l_n - 1), prpad, ' ')
                END;
            l_str := SUBSTR (l_str, l_n + 1);
        END LOOP;

        RETURN l_data;
    END;



    FUNCTION str4size_delim (p_str     VARCHAR2,
                             p_siz     INTEGER,
                             p_delim   VARCHAR2,
                             p_centr   INT:= 0)
        RETURN VARCHAR2
    AS
        l_str    VARCHAR2 (32765) := '';
        l_tmp    VARCHAR2 (1000) := '';
        l_tmp2   VARCHAR2 (1000) := '';
        l_ext    VARCHAR2 (32765);
    --l_cnt number;
    BEGIN
        l_str := p_str;

        WHILE LENGTH (l_str) > 0
        LOOP
            --режу по размеру
            l_tmp := SUBSTR (l_str, 1, p_siz);

            --режу по последнему пробелу
            IF INSTR (l_tmp, ' ', -1) > 0 AND LENGTH (l_tmp) >= p_siz
            THEN
                l_tmp := SUBSTR (l_tmp, 1, INSTR (l_tmp, ' ', -1) - 1);
            END IF;

            --если есть парсер - режу по парсер
            IF INSTR (l_tmp, p_delim) > 0
            THEN
                l_tmp := SUBSTR (l_tmp, 1, INSTR (l_tmp, p_delim) - 1);
            END IF;

            IF p_centr > 0
            THEN
                l_tmp2 := PrintCenter (l_tmp, p_centr);
            ELSE
                l_tmp2 := l_tmp;
            END IF;

            --загоняю значения
            l_ext := l_ext || p_delim || l_tmp2;
            --режу временную переменную
            l_str := SUBSTR (l_str, LENGTH (l_tmp) + 2);
        END LOOP;

        IF LENGTH (l_ext) = 0
        THEN
            l_ext := p_delim;
        ELSE
            l_ext := SUBSTR (l_ext, 2, LENGTH (l_ext));
        END IF;

        RETURN l_ext;
    END;


    FUNCTION str4size_tbl (p_str VARCHAR2, p_siz INTEGER)
        RETURN T_ARRVAR
    AS
    BEGIN
        RETURN str2tbl (str4size_delim (p_str, p_siz, '|'), '|');
    END;


    -- місяць в родовому відмінку
    FUNCTION get_mnth_pad_name (p_mnth IN NUMBER)
        RETURN VARCHAR2
    IS
        v_mnth_name   VARCHAR2 (30);
    BEGIN
        CASE
            WHEN p_mnth = 1
            THEN
                v_mnth_name := 'Січня';
            WHEN p_mnth = 2
            THEN
                v_mnth_name := 'Лютого';
            WHEN p_mnth = 3
            THEN
                v_mnth_name := 'Березня';
            WHEN p_mnth = 4
            THEN
                v_mnth_name := 'Квітня';
            WHEN p_mnth = 5
            THEN
                v_mnth_name := 'Травня';
            WHEN p_mnth = 6
            THEN
                v_mnth_name := 'Червня';
            WHEN p_mnth = 7
            THEN
                v_mnth_name := 'Липня';
            WHEN p_mnth = 8
            THEN
                v_mnth_name := 'Серпня';
            WHEN p_mnth = 9
            THEN
                v_mnth_name := 'Вересеня';
            WHEN p_mnth = 10
            THEN
                v_mnth_name := 'Жовтня';
            WHEN p_mnth = 11
            THEN
                v_mnth_name := 'Листопада';
            WHEN p_mnth = 12
            THEN
                v_mnth_name := 'Грудня';
            ELSE
                v_mnth_name := '';
        END CASE;

        RETURN v_mnth_name;
    END;

    -- месяц укр. в дательном падеже
    FUNCTION get_mnth_dav_name (p_mnth IN NUMBER)
        RETURN VARCHAR2
    IS
        v_mnth_name   VARCHAR2 (30);
    BEGIN
        CASE
            WHEN p_mnth = 1
            THEN
                v_mnth_name := 'Січні';
            WHEN p_mnth = 2
            THEN
                v_mnth_name := 'Лютому';
            WHEN p_mnth = 3
            THEN
                v_mnth_name := 'Березні';
            WHEN p_mnth = 4
            THEN
                v_mnth_name := 'Квітні';
            WHEN p_mnth = 5
            THEN
                v_mnth_name := 'Травні';
            WHEN p_mnth = 6
            THEN
                v_mnth_name := 'Червні';
            WHEN p_mnth = 7
            THEN
                v_mnth_name := 'Липні';
            WHEN p_mnth = 8
            THEN
                v_mnth_name := 'Серпні';
            WHEN p_mnth = 9
            THEN
                v_mnth_name := 'Вересні';
            WHEN p_mnth = 10
            THEN
                v_mnth_name := 'Жовтні';
            WHEN p_mnth = 11
            THEN
                v_mnth_name := 'Листопаді';
            WHEN p_mnth = 12
            THEN
                v_mnth_name := 'Грудні';
            ELSE
                v_mnth_name := '';
        END CASE;

        RETURN v_mnth_name;
    END;


    --- відомості на виплату, форма B-1M
    PROCEDURE BuildPaymentB1M (p_pr_id   IN            payroll.pr_id%TYPE,
                               ---p_org_id in payroll.com_org%type,
                               p_rpt     IN OUT NOCOPY BLOB)
    IS
        p_asopd                  VARCHAR2 (10) := '';
        ---l_org_id     payroll.com_org%type;
        l_buff                   VARCHAR2 (32767);
        l_buff2                  VARCHAR2 (32767);
        l_pr_start_dt            payroll.pr_start_dt%TYPE;
        l_opfu_name              v_opfu.org_name%TYPE;
        l_per_year               NUMBER (4);      ---nsi_period.per_year%type;
        l_per_month              NUMBER (2);     ---nsi_period.per_month%type;
        l_date_start             VARCHAR2 (10);
        l_date_stop              VARCHAR2 (10);
        l_per_num                NUMBER (14) := 1; --  Виплатний період ?????  payroll.pr_per_num%type;
        l_ved_tp                 CHAR (20);
        l_prs_num                pr_sheet.prs_num%TYPE DEFAULT 0;
        l_org_id                 v_opfu.ORG_ID%TYPE DEFAULT 0;
        l_prs_index              uss_ndi.v_ndi_post_office.npo_index%TYPE DEFAULT NULL;
        l_rn_rep                 PLS_INTEGER DEFAULT 0;
        l_sum_tab                NUMBER;
        l_sum_text               VARCHAR2 (512);
        n                        NUMBER := 1;
        v_address_1              VARCHAR2 (100);
        v_address_2              VARCHAR2 (100);
        v_count                  NUMBER;
        v_instr                  NUMBER;
        l_a_pr_name              VARCHAR2 (100);
        l_a_per_num              VARCHAR2 (20) := 1; --  Виплатний період ?????
        l_npc_name               VARCHAR2 (100);
        l_npc_code               VARCHAR2 (100);
        --l_page_width number := 134;
        --
        Ct_pnf_pib_LENGTH        INTEGER := 19;
        CT_ADDRESS_LENGTH        INTEGER := 30;
        CT_PASSPORT_LENGTH       INTEGER := 15                          /*10*/
                                              ;       --  різні довідки і т.д.
        CT_OPFU_LENGTH           INTEGER := 75;
        CT_CNTR_LENGTH           INTEGER := 28;
        CT_SUM_TEXT_TAB_LENGTH   INTEGER := 103;
        CT_SUM_RTAB_LENGTH       INTEGER := 26;
        CT_MAIN_PIB_LENGTH       INTEGER := 28;
        CT_BUCH_PIB_LENGTH       INTEGER := 45;
        --
        l_header_tab             VARCHAR2 (32767)
            :=    /*    '                                                                                                             АРК   <PAGE_NUM>    ' || chr(13) || chr(10) ||
                      '                                          B I Д O M I C T Ь  N   <RN_IND>/<ORG_CODE>                               . ВIДР TAЛ.N<RN_IND>/<ORG_CODE>' || chr(13) || chr(10) ||
                      '               НА ВИПЛАТУ ГРОШОВОЇ <NPC_NAME> ЗА <PER_MONTH> <PER_YEAR>           <PP_DATE> .     <PER_MONTH> <PER_YEAR>' || chr(13) || chr(10) ||
                      '<ASOPD>     <PSP_TP2> . ТИП ВIДОМОСТI <PSP_TP>' || chr(13) || chr(10) ||
                      '                  ЗА  <DLVR_CODE> ДOCTABНОЮ ДIЛЬНИЦЕЮ <prs_index> ВИПЛ. ОБ`ЄКТА ПОШТ. ЗВ.                               . <ORG_CODE>  УО        <PP_DAY> Д/В' || chr(13) || chr(10) ||
                      ' <OPFU_NAME>  <CNTR_NAME> . <prs_index> ВО       <DLVR_CODE> Д/Д' || chr(13) || chr(10) ||*/
                  -- io 20230324 НА ВИПЛАТУ ГРОШОВОЇ - прибрав
                  '                                                                                                             АРК   <PAGE_NUM>    '
               || CHR (13)
               || CHR (10)
               || '                                          B I Д O M I C T Ь  N   <RN_IND>/<ORG_CODE>                               . ВIДР TAЛ.N<RN_IND>/<ORG_CODE>'
               || CHR (13)
               || CHR (10)
               || '   <NPC_NAME>   <PP_DATE> .     <PER_MONTH> <PER_YEAR>'
               || CHR (13)
               || CHR (10)
               || '<ASOPD>  <NPC_NAME2>  ЗА <PER_MONTH> <PER_YEAR>     <PSP_TP2> . ТИП ВIДОМОСТI <PSP_TP>'
               || CHR (13)
               || CHR (10)
               || '                  ЗА  <DLVR_CODE> ДOCTABНОЮ ДIЛЬНИЦЕЮ <prs_index> ВИПЛ. ОБ`ЄКТА ПОШТ. ЗВ.                               . <ORG_CODE>  УО        <PP_DAY> Д/В'
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME>  <CNTR_NAME> . <prs_index> ВО       <DLVR_CODE> Д/Д'
               || CHR (13)
               || CHR (10)
               || --case when p_asopd is not null then ' '||p_asopd|| chr(13) || chr(10) end||
                  ' ----------+-------------------+------------------------------+----------+---------------+----+----+------ . +----------+----------+--'
               || CHR (13)
               || CHR (10)
               || '    N ОС.  ¦ ПРIЗВИЩЕ,ВЛАСНЕ   ¦                              ¦   CУMA   ¦ПАС,АБО ДОК,ЩО ¦ДATA¦ПIДП¦ПIД ПР . ¦   CУMA   ¦   N ОС.  ¦ПP'
               || CHR (13)
               || CHR (10)
               || '   РАХ.ОД  ¦IM`Я ТА ПО БАТЬКОВI¦       МIСЦЕ ПРОЖИВАННЯ       ¦СОЦ. ДОПОМ¦ПОС ОС(СЕР,НОМ)¦BИПЛ¦OДЕР¦ВИП ОБ . ¦СОЦ. ДОПОМ¦  РАХУНК  ¦  '
               || CHR (13)
               || CHR (10)
               || ' ----------+-------------------+------------------------------+----------+---------------+----+----+------ . +----------+----------+--'
               || CHR (13)
               || CHR (10);
        l_body_tab               VARCHAR2 (32767)
            :=    '<I><PNF_NUMBER>¦<prs_pib1>¦<ADDRESS1>¦<PP_SUM>¦<PNF_PASP>¦    ¦    ¦       . ¦<PP_SUM>¦<PNF_NUMBER>¦<I> '
               || CHR (13)
               || CHR (10)
               || ' <D>         ¦<prs_pib2>¦<ADDRESS2>+----------+---------------+----+----+------ . +----------+----------+--'
               || CHR (13)
               || CHR (10);
        l_body_line3             VARCHAR2 (1000)
            :=    '             ¦<prs_pib3>¦<ADDRESS3>+----------+---------------+----+----+------ . +----------+----------+--'
               || CHR (13)
               || CHR (10);

        l_footer_tab             VARCHAR2 (32767)
            :=    ' ----------+-------------------+------------------------------+----------+---------------+----+----+------ . +----------+----------+--'
               || CHR (13)
               || CHR (10)
               || ' HAРАХОВАНО:  KIЛЬКIСТЬ <RN_IND> CУMA СОЦ.ДОПОМОГИ:  <SUM_TAB>                                            . HAРАХОВАНО: '
               || CHR (13)
               || CHR (10)
               || ' <SUM_TEXT1_TAB>  .   K-ТЬ: <RN_IND>'
               || CHR (13)
               || CHR (10)
               || '  <SUM_TEXT2_TAB>  .   СУМА:<SUM_TAB>'
               || CHR (13)
               || CHR (10)
               || '                                                                                                           . <SUM_TEXT1_RTAB>'
               || CHR (13)
               || CHR (10)
               || '            М.П.   ВIДПОВIДАЛЬНИЙ ПРАЦIВНИК УПОВНОВАЖЕНОГО ОРГАНУ _____________<PR_MAIN_PIB>. <SUM_TEXT2_RTAB>'
               || CHR (13)
               || CHR (10)
               || '                                                                       (ПIДПИС)                            . <SUM_TEXT3_RTAB>'
               || CHR (13)
               || CHR (10);
        l_footer_tab_end         VARCHAR2 (32767)
            := '                                                                                                           . ';
        l_footer_doc             VARCHAR2 (32767)
            :=    ' --------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------  . -------------------------'
               || CHR (13)
               || CHR (10)
               || '  ДATA         ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦          .   HE ВИПЛАЧЕНО:      '
               || CHR (13)
               || CHR (10)
               || ' --------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------  .   K-ТЬ: _________________'
               || CHR (13)
               || CHR (10)
               || '  CУMA ЗA ДEHЬ ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦          .   CУMA: _________________'
               || CHR (13)
               || CHR (10)
               || ' --------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------  .            (цифр. слов)   '
               || CHR (13)
               || CHR (10)
               || '  З ПОЧ. MIC.  ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦        ¦          .   ШТАМП                '
               || CHR (13)
               || CHR (10)
               || ' --------------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------  . ВIДПОВIД ПРАЦ ВИПЛАТ     '
               || CHR (13)
               || CHR (10)
               || '    СУМА НЕВИПЛАЧЕНИХ СОЦ ДОПОМОГ НА КIНЕЦЬ ВИПЛАТНОГО ПЕРIОДУ ЗА ВIДОМIСТЮ _____________________________  . ОБ`ЄКТА       ___________'
               || CHR (13)
               || CHR (10)
               || 'ШТАМП   ВIДПОВIДАЛЬНИЙ ПРАЦIВНИК ВИПЛАТНОГО ОБ`ЄКТА ____________________________<PR_BUCH_PIB>(пiдп)'
               || CHR (13)
               || CHR (10);


        l_page_num               NUMBER := 0;
        l_row_num                NUMBER := 0;
        l_rep                    t_b1m_table;


        PROCEDURE PageHeader
        IS
        BEGIN
            l_buff2 :=
                   ' -------------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CHR (12)
                || ' -------------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF l_row_num = 0
            THEN
                l_buff := REPLACE (l_buff, '', '');
            END IF;

            l_page_num := l_page_num + 1;
            l_row_num := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE TabHeader (
            p_prs_num            IN pr_sheet.prs_num%TYPE,
            p_prs_index          IN VARCHAR2,    --v_nsi_index.prs_index%type,
            p_cntr_name          IN uss_ndi.v_ndi_comm_node.ncn_name%TYPE,
            p_dlvr_code          IN uss_ndi.v_ndi_delivery.nd_code%TYPE,
            p_pp_date            IN pr_sheet.prs_pay_dt%TYPE,
            p_is_payed_on_post   IN INTEGER,
            p_pp_day             IN VARCHAR2,
            p_per_month          IN VARCHAR2,
            p_per_year           IN VARCHAR2,      --nsi_period.per_year%type,
            p_opfu_name          IN v_opfu.ORG_NAME%TYPE,
            p_org_code           IN v_opfu.ORG_CODE%TYPE,
            p_pr_tp              IN VARCHAR2)
        IS
        BEGIN
            l_buff := l_header_tab;
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME>',
                    PrintLeft (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                1,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 90 /*70*/
                                                                       ),
                                       ' ',
                                       -1))),
                        90));                       -- substr(l_npc_name,1,70)
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME2>',
                    PrintRight (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 70),
                                       ' ',
                                       -1),
                                50)),
                        50));                      -- substr(l_npc_name,71,50)
            l_buff :=
                REPLACE (l_buff, '<PER_MONTH>', PrintLeft (p_per_month, 8));
            l_buff :=
                REPLACE (l_buff,
                         '<PER_YEAR>',
                         PrintLeft (p_per_year || ' Р.', 7));
            l_buff :=
                REPLACE (
                    l_buff,
                    '<OPFU_NAME>',
                    PrintLeft (SUBSTR (p_opfu_name, 1, CT_OPFU_LENGTH),
                               CT_OPFU_LENGTH));
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_CODE>',
                         PrintLeft (TO_CHAR (p_org_code), 5));
            l_buff :=
                REPLACE (l_buff,
                         '<PSP_TP>',
                         PrintRight (p_pr_tp || l_a_per_num, 11         /*13*/
                                                               ));
            l_buff :=
                REPLACE (
                    l_buff,
                    '<PSP_TP2>',
                    PrintRight ('ТИП ВIДОМОСТI ' || p_pr_tp || l_a_pr_name,
                                27));

            l_rn_rep := 0;
            l_sum_tab := 0;

            IF (p_is_payed_on_post = 1)
            THEN
                l_buff :=
                    REPLACE (
                        REPLACE (l_buff,
                                 'ЗА  <DLVR_CODE> ДOCTABНОЮ ДIЛЬНИЦЕЮ',
                                 PrintLeft (' ', 27)),
                        'ВИПЛ. ОБ`ЄКТА ПОШТ. ЗВ.                          ',
                        PrintLeft (
                            'ВИПЛ. ОБ`ЄКТА ПОШТ. ЗВ. (ДЛЯ ВИПЛАТИ В КАСІ)',
                            49));
                l_buff :=
                    REPLACE (l_buff,
                             'П/В   <DLVR_CODE> Д/Д',
                             'П/В       Д/Д');
            END IF;

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                l_buff,
                                                '<PAGE_NUM>',
                                                PrintLeft (
                                                    TO_CHAR (l_page_num),
                                                    10)),
                                            '<RN_IND>',
                                            PrintRight (TO_CHAR (p_prs_num),
                                                        5)),
                                        '<prs_index>',
                                        PrintLeft (
                                            LPAD (
                                                TRIM (
                                                    TO_CHAR (p_prs_index,
                                                             '99990')),
                                                5,
                                                '0'),
                                            6)),
                                    '<ASOPD>', /*PrintLeft(nvl(to_char(p_asopd),' '),7)*/
                                    ' '),
                                '<CNTR_NAME>',                   /*PrintLeft*/
                                PrintRight (
                                    SUBSTR (p_cntr_name, 1, CT_CNTR_LENGTH),
                                    CT_CNTR_LENGTH)),
                            '<DLVR_CODE>',
                            PrintRight (
                                COALESCE (TO_CHAR (p_dlvr_code), ' '),
                                3)),
                        '<PP_DATE>',
                        PrintRight (TO_CHAR (p_pp_date, 'dd.mm.yyyy'), 10)),
                    '<PP_DAY>',
                    PrintRight (p_pp_day, 2));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 10;
        END;

        --
        PROCEDURE TabBody (p_pnf_number              IN VARCHAR2,
                           p_pp_sum                  IN pr_sheet.prs_sum%TYPE,
                           p_prs_pib                 IN VARCHAR2,
                           p_address                 IN VARCHAR2,
                           p_pnf_pasp                IN VARCHAR2, -- document.doc_number%type,
                           p_ind_lim_value           IN NUMBER, -- v_nsi_index.ind_lim_value%type,
                           p_prs_index               IN VARCHAR2, --v_nsi_index.prs_index%type,
                           p_d                       IN CHAR,
                           p_is_high_prior_recieve   IN CHAR)
        IS
            v_sum        VARCHAR2 (30)
                             := TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '9999990.00'));
            l_prs_pib1   VARCHAR2 (255);
            l_prs_pib2   VARCHAR2 (255);

            --
            PROCEDURE get_pnf_pib
            IS
                p1   INTEGER := INSTR (p_prs_pib, ' ', 1);
                p2   INTEGER := INSTR (p_prs_pib, ' ', -1);
                w    INTEGER := LENGTH (p_prs_pib);
            BEGIN
                l_prs_pib1 :=
                    CASE
                        WHEN w - p1 > p2 - 1
                        THEN
                            SUBSTR (p_prs_pib, 1, p2 - 1)
                        ELSE
                            SUBSTR (p_prs_pib, 1, p1 - 1)
                    END;
                l_prs_pib2 :=
                    CASE
                        WHEN w - p1 > p2 - 1
                        THEN
                            SUBSTR (p_prs_pib, p2 + 1, w - p2)
                        ELSE
                            SUBSTR (p_prs_pib, p1 + 1, w - p1)
                    END;

                IF GREATEST (LENGTH (l_prs_pib1), LENGTH (l_prs_pib2)) >
                   Ct_pnf_pib_LENGTH
                THEN
                    l_prs_pib1 := SUBSTR (p_prs_pib, 1, Ct_pnf_pib_LENGTH);
                    l_prs_pib2 :=
                        SUBSTR (p_prs_pib,
                                Ct_pnf_pib_LENGTH + 1,
                                Ct_pnf_pib_LENGTH);
                END IF;
            --case when w > Ct_pnf_pib_LENGTH * 2 then substr(p_prs_pib,1,Ct_pnf_pib_LENGTH);
            --when w > Ct_pnf_pib_LENGTH * 2 then substr(p_prs_pib,Ct_pnf_pib_LENGTH + 1,Ct_pnf_pib_LENGTH);
            END;
        BEGIN
            l_rn_rep := l_rn_rep + 1;
            get_pnf_pib;

            /*    if p_ind_lim_value<p_pp_sum then
                  raise_application_error(-20000, 'Знайдена пенсійна виплата, яка перевищує ліміт.
                                                   Індекс поштового зв`язку '||to_char(p_prs_index)||',
                                                   сума ліміту = '||to_char(p_ind_lim_value)||',
                                                   номер пенсійної справи '||p_pnf_number||',
                                                   сума виплати = '||v_sum);
                end if;*/

            v_count :=
                REGEXP_COUNT (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH), ',');

            IF v_count > 0
            THEN
                v_instr :=
                    INSTR (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                           ',',
                           1,
                           v_count);
            ELSE
                v_instr := 0;
            END IF;

            IF     (LENGTH (p_address) > CT_ADDRESS_LENGTH)
               AND (v_count > 0)
               AND (LENGTH (p_address) - v_instr < 30 + 1)
            THEN
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, V_INSTR), ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    V_INSTR + 1 + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            ELSE
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                                  ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    CT_ADDRESS_LENGTH + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            END IF;

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                REPLACE (
                                                    l_body_tab,
                                                    '<PNF_NUMBER>',
                                                    PrintLeft (p_pnf_number,
                                                               10)),
                                                '<D>',
                                                PrintLeft (p_d, 1)),
                                            '<I>',
                                            PrintLeft (
                                                COALESCE (
                                                    p_is_high_prior_recieve,
                                                    ' '),
                                                1)),
                                        '<prs_pib1>',
                                        PrintLeft (
                                            COALESCE (l_prs_pib1, ' '),
                                            19)),
                                    '<prs_pib2>',
                                    PrintLeft (COALESCE (l_prs_pib2, ' '),
                                               19)),
                                -- http://redmine.dev.ua/redmine/issues/31978: Номер будинку друкується в двох рядках
                                --      '<ADDRESS1>', PrintLeft(coalesce(substr(p_address,1,CT_ADDRESS_LENGTH),' '),CT_ADDRESS_LENGTH)),
                                --      '<ADDRESS2>', PrintLeft(coalesce(substr(p_address,CT_ADDRESS_LENGTH+1,CT_ADDRESS_LENGTH),' '),CT_ADDRESS_LENGTH)),
                                '<ADDRESS1>',
                                v_address_1),
                            '<ADDRESS2>',
                            v_address_2),
                        '<PNF_PASP>',
                        PrintLeft (COALESCE (p_pnf_pasp, ' '),
                                   CT_PASSPORT_LENGTH)),
                    '<PP_SUM>',
                    PrintRight (v_sum, 10));

            DECLARE
                l_index3      INTEGER
                                  := CT_ADDRESS_LENGTH + CT_ADDRESS_LENGTH + 1;
                l_len3        INTEGER := CT_ADDRESS_LENGTH;
                l_max_line3   INTEGER := 3;
                i3            INTEGER := 0;
                l_address3    VARCHAR2 (255)
                                  := SUBSTR (p_address, l_index3, l_len3);
                l_buff3       VARCHAR2 (5000);
                --
                l_index4      INTEGER
                    := Ct_pnf_pib_LENGTH + Ct_pnf_pib_LENGTH + 1;
                l_len4        INTEGER := Ct_pnf_pib_LENGTH;
                l_name4       VARCHAR2 (255)
                                  := SUBSTR (p_prs_pib, l_index4, l_len4);
            BEGIN
                WHILE     (l_address3 IS NOT NULL OR l_name4 IS NOT NULL)
                      AND i3 < l_max_line3
                LOOP
                    l_buff3 :=
                        REPLACE (
                            REPLACE (
                                l_body_line3,
                                '<ADDRESS3>',
                                PrintLeft (COALESCE (l_address3, ' '),
                                           l_len3)),
                            '<prs_pib3>',
                            PrintLeft (COALESCE (l_name4, ' '), l_len4));
                    l_index3 := l_index3 + l_len3;
                    l_index4 := l_index4 + l_len4;
                    l_address3 := SUBSTR (p_address, l_index3, l_len3);
                    l_name4 := SUBSTR (p_prs_pib, l_index4, l_len4);
                    l_buff := l_buff || l_buff3;
                    i3 := i3 + 1;
                END LOOP;
            END;

            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE TabFooter
        IS
            v_index   PLS_INTEGER DEFAULT 64;
            v_text    VARCHAR2 (21);
        BEGIN
            l_sum_text := '(' || UPPER (sum_to_text (l_sum_tab)) || ')';
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                l_footer_tab,
                                                '<RN_IND>',
                                                PrintCenter (
                                                    TO_CHAR (l_rn_rep),
                                                    3)),
                                            '<SUM_TEXT1_TAB>',
                                            PrintLeft (
                                                SUBSTR (
                                                    l_sum_text,
                                                    1,
                                                    CT_SUM_TEXT_TAB_LENGTH),
                                                CT_SUM_TEXT_TAB_LENGTH + 1)),
                                        '<SUM_TEXT2_TAB>',
                                        PrintLeft (
                                            COALESCE (
                                                SUBSTR (
                                                    l_sum_text,
                                                      CT_SUM_TEXT_TAB_LENGTH
                                                    + 1,
                                                    CT_SUM_TEXT_TAB_LENGTH),
                                                ' '),
                                            CT_SUM_TEXT_TAB_LENGTH)),
                                    '<SUM_TEXT1_RTAB>',
                                    PrintLeft (
                                        SUBSTR (l_sum_text,
                                                1,
                                                CT_SUM_RTAB_LENGTH      /*27*/
                                                                  ),
                                        CT_SUM_RTAB_LENGTH)),
                                '<PR_MAIN_PIB>',
                                PrintLeft (
                                    SUBSTR (''        /*tools.GetCurrUserPIB*/
                                              , 1, CT_MAIN_PIB_LENGTH   /*28*/
                                                                     ),
                                    CT_MAIN_PIB_LENGTH)),
                            '<SUM_TEXT2_RTAB>',
                            PrintLeft (
                                COALESCE (
                                    SUBSTR (l_sum_text,                 /*28*/
                                            CT_SUM_RTAB_LENGTH + 1,
                                            CT_SUM_RTAB_LENGTH),
                                    ' '),
                                CT_SUM_RTAB_LENGTH)),
                        '<SUM_TEXT3_RTAB>',
                        PrintLeft (
                            COALESCE (
                                SUBSTR (l_sum_text,
                                        CT_SUM_RTAB_LENGTH * 2 + 1,
                                        CT_SUM_RTAB_LENGTH),
                                ' '),
                            CT_SUM_RTAB_LENGTH)),
                    '<SUM_TAB>',
                    PrintRight (
                        TRIM (TO_CHAR (l_sum_tab, '999999999990.00')),
                        15));
            v_text := SUBSTR (l_sum_text, v_index, 21);

            WHILE v_text IS NOT NULL
            LOOP
                l_buff :=
                       l_buff
                    || l_footer_tab_end
                    || v_text
                    || CHR (13)
                    || CHR (10);
                v_index := v_index + 21;
                v_text := SUBSTR (l_sum_text, v_index, 21);
            END LOOP;

            l_buff :=
                   l_buff
                || l_footer_tab_end
                || CHR (13)
                || CHR (10)
                || REPLACE (l_footer_doc,
                            '<PR_BUCH_PIB>',
                            PrintLeft ( /*#97222 substr(tools.GetCurrUserPIB '',1, CT_BUCH_PIB_LENGTH)*/
                                       '', CT_BUCH_PIB_LENGTH));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT CASE
                   WHEN pr_tp = 'A'
                   THEN
                       SUBSTR (
                              ''                 --' КАТЕГОРІЯ ' || t.npt_code
                           || ' ПЕРІОД '
                           ||                                           -- l_per_num
                              (SELECT COUNT (1)
                                 FROM v_payroll p2
                                WHERE     p2.pr_month = pr.pr_month
                                      AND p2.com_org = pr.com_org
                                      AND p2.pr_npc = pr.pr_npc
                                      AND p2.pr_pay_tp = pr.pr_pay_tp
                                      ---and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                      AND p2.pr_create_dt <= pr.pr_create_dt)
                           || ' '
                           || c.npc_name,
                           1,
                           79)
                   ELSE
                       ''
               END,
                  ' ПЕРІОД '
               ||                                                     /*pr_per_num*/
                                                                        -- l_per_num
                  (SELECT COUNT (1)
                     FROM v_payroll p2
                    WHERE     p2.pr_month = pr.pr_month
                          AND p2.com_org = pr.com_org
                          AND p2.pr_npc = pr.pr_npc
                          AND p2.pr_pay_tp = pr.pr_pay_tp
                          --and p2.pr_tp = pr.pr_tp  --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                          AND p2.pr_create_dt <= pr.pr_create_dt),
               npc_name,
               npc_code
          INTO l_a_pr_name,
               l_a_per_num,
               l_npc_name,
               l_npc_code
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr.pr_npc
         WHERE pr_id = p_pr_id;

        FOR rec IN (SELECT com_org     AS org_id           --distinct o.org_id
                      FROM payroll p
                     WHERE pr_id = p_pr_id/* order by o.org_id*/
                                          )
        LOOP
            l_org_id := 0;
            l_prs_index := NULL;

            OPEN c_b1m (p_pr_id            /*, 'P', 'F', rec.org_id, p_asopd*/
                               );

            FETCH c_b1m BULK COLLECT INTO l_rep;

            CLOSE c_b1m;

            IF l_rep.COUNT = 0
            THEN
                RAISE NO_DATA_FOUND;
            END IF;

            FOR i IN l_rep.FIRST .. l_rep.LAST
            LOOP
                DBMS_OUTPUT.put_line (
                       l_rep (i).prs_num
                    || '-'
                    || l_rep (i).prs_index
                    || l_rep (i).dlvr_code);

                IF    NVL (l_rep (i).org_id, -1) != l_org_id
                   OR NVL (l_rep (i).prs_num, -1) != l_prs_num
                   OR NVL (l_rep (i).prs_index, -1) != l_prs_index
                THEN
                    IF l_prs_num != 0
                    THEN
                        TabFooter;
                    END IF;

                    PageHeader;
                    --n:=i;
                    --raise_application_error(-20001, l_rep(i).prs_index);
                    TabHeader (
                        p_prs_num            => l_rep (i).prs_num,
                        p_prs_index          => l_rep (i).prs_index,
                        p_cntr_name          => l_rep (i).ncn_name,
                        p_dlvr_code          => l_rep (i).dlvr_code,
                        p_pp_date            => l_rep (i).pp_date,
                        p_is_payed_on_post   => l_rep (i).is_payed_on_post,
                        p_pp_day             => l_rep (i).pp_day,
                        p_per_month          => l_rep (i).per_month,
                        p_per_year           => l_rep (i).per_year,
                        p_opfu_name          =>
                            get_org_sname (l_rep (i).opfu_name),
                        p_org_code           => l_rep (i).org_code,
                        p_pr_tp              => l_npc_code --  #85524 l_rep(i).pr_tp
                                                          );
                END IF;

                TabBody (
                    p_pnf_number      => l_rep (i).prs_pc_num,
                    p_pp_sum          => l_rep (i).prs_sum,
                    p_prs_pib         => l_rep (i).prs_pib,
                    p_address         => l_rep (i).address,
                    p_pnf_pasp        => l_rep (i).pnf_pasp,
                    p_ind_lim_value   => l_rep (i).ind_lim_value,
                    p_prs_index       => l_rep (i).prs_index,
                    p_d               => l_rep (i).d,
                    p_is_high_prior_recieve   =>
                        l_rep (i).is_high_prior_recieve);

                l_org_id := NVL (l_rep (i).org_id, -1);
                l_prs_num := NVL (l_rep (i).prs_num, -1);
                l_prs_index := NVL (l_rep (i).prs_index, -1);
            END LOOP;
        END LOOP;

        TabFooter;
        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "Відомість на виплату форма B1-M"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Відомість на виплату форма B1-M": '
                || ', n='
                || TO_CHAR (n)
                || ' '
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPaymentB1M;


    PROCEDURE BuildPaymentB4M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd  in v_asopd2opfu.asop_org%type,
                               p_rpt     IN OUT NOCOPY BLOB)
    IS
        p_asopd             VARCHAR2 (10) := '';
        l_buff              VARCHAR2 (32767);
        l_sum_tab           NUMBER := 0;
        l_sum_ind           NUMBER := 0;
        l_sum_ind_ispost    NUMBER := 0;
        l_count_ind         NUMBER := 0;
        l_count_tab         NUMBER := 0;
        l_sum_text          VARCHAR2 (512);
        l_org_num           NUMBER := 0;
        l_index_num         NUMBER := 0;
        l_row_num           NUMBER := 0;
        l_row_day           NUMBER := 0;
        l_page_width        NUMBER := 65;
        l_page_height       NUMBER := 67;            -- CT_MAX_REPORT_ROW_TXT;
        l_prs_index         uss_ndi.v_ndi_post_office.npo_index%TYPE := -1;
        l_count             INTEGER := 0;
        l_org_id            v_opfu.org_id%TYPE := 0;
        l_ncn_name          uss_ndi.v_ndi_comm_node.ncn_name%TYPE;
        l_a_pr_name         VARCHAR2 (100);
        l_per_num           NUMBER := 1;
        l_npc_name          VARCHAR2 (100);
        l_page_header_tmp   VARCHAR2 (32767)
            :=    '                                                         '
               || CHR (13)
               || CHR (10)
               || '                                         АРКУШ <IND_NUM>(<ORG_NUM>)'
               || CHR (13)
               || CHR (10)
               || --    '                           P E Є C T P  №' || chr(13) || chr(10) ||
                  --    '             BIДOMOCTEЙ, НА ВИПЛАТУ ГРОШОВОЇ' || chr(13) || chr(10) ||
                  PrintCenter ('P E Є C T P  №  ', l_page_width)
               || CHR (13)
               || CHR (10)
               || PrintCenter ('BIДOMOCTEЙ, НА ВИПЛАТУ ГРОШОВОЇ',
                               l_page_width)
               || CHR (13)
               || CHR (10)
               || ' <NPC_NAME> '
               || CHR (13)
               || CHR (10)
               || '  <NPC_NAME2> ЗА <PER_MONTH> <PER_YEAR>'
               || CHR (13)
               || CHR (10)
               || --   '            <NPC_NAME> ЗА <PER_MONTH> <PER_YEAR>' || chr(13) || chr(10) ||
                  ''
               || CHR (13)
               || CHR (10)
               || '               HA ПEPIOД З <PSP_START_DT> ПO <PSP_STOP_DT>'
               || CHR (13)
               || CHR (10)
               || '    ВИПЛАТНИЙ ОБ`ЄКТ                                   <IND_IND>'
               || CHR (13)
               || CHR (10)
               || '    ВУЗОЛ ПОШТ ЗВ`ЯЗКУ <CNTR_NAME>'
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME>'
               ||                                    /*chr(13) || chr(10) ||*/
                  ' ТИП ВIДОМОСТI <PSP_TP>'
               || CHR (13)
               || CHR (10)
               || -- case when p_asopd is not null then PrintLeft(substr(' '||p_asopd,1,48),48)|| chr(13) || chr(10) end||
                  '      +-------+-----------+-----------+----------------+-----+'
               || CHR (13)
               || CHR (10)
               || '      ¦ ДATA  ¦   НОМЕР   ¦ КIЛЬКIСТЬ ¦ЗАГ СУМА ДО ВИПЛ¦ПРИМI¦'
               || CHR (13)
               || CHR (10)
               || '      ¦BИПЛATИ¦ BIДOMOCTI ¦OДЕРЖУВАЧIВ¦                ¦ТКИ  ¦'
               || CHR (13)
               || CHR (10)
               || '      +-------+-----------+-----------+----------------+-----+'
               || CHR (13)
               || CHR (10)
               || '      ¦   1   ¦     2     ¦     3     ¦       4        ¦  5  ¦'
               || CHR (13)
               || CHR (10)
               || '      +-------+-----------+-----------+----------------+-----+'
               || CHR (13)
               || CHR (10);
        l_page_header       VARCHAR2 (32767) := l_page_header_tmp;
        l_tab_header_tmp    VARCHAR2 (32767)
            :=    '         ВИПЛАТНИЙ ОБ`ЄКТ <IND_IND>  АРКУШ <IND_NUM>(<ORG_NUM>)'
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME> <CNTR_NAME>'
               || CHR (13)
               || CHR (10)
               || '      +-------+-----------+-----------+----------------+-----+'
               || CHR (13)
               || CHR (10)
               || '      ¦   1   ¦     2     ¦     3     ¦        4       ¦  5  ¦'
               || CHR (13)
               || CHR (10)
               || '      +-------+-----------+-----------+----------------+-----+'
               || CHR (13)
               || CHR (10);
        l_tab_header        VARCHAR2 (32767) := l_tab_header_tmp;
        l_tab_body          VARCHAR2 (32767)
            :=    '      ¦   <PP_DAY>   <RN_IND>     <ROW_COUNT>     <PP_SUM>           ¦'
               || CHR (13)
               || CHR (10);
        l_tab_footer        VARCHAR2 (32767)
            :=    '      ¦                                                      ¦'
               || CHR (13)
               || CHR (10)
               || '      ¦ УСЬОГО             <ROW_COUNT_TAB>     <PP_SUM_TAB>           ¦'
               || CHR (13)
               || CHR (10)
               || '      ¦                                                      ¦'
               || CHR (13)
               || CHR (10);
        l_page_footer       VARCHAR2 (32767)
            :=    '      +------------------------------------------------------+'
               || CHR (13)
               || CHR (10)
               || '    У C Ь О Г O            <COUNT_IND>  <SUM_IND>'
               || CHR (13)
               || CHR (10)
               || '    У ТОМУ ЧИСЛI ЗА ВIДОМОСТЯМИ З ВIДМIТКОЮ'
               || CHR (13)
               || CHR (10)
               || '    `ДЛЯ ВИПЛАТИ В КАСI`            <SUM_IND_ISPOST>'
               || CHR (13)
               || CHR (10)
               || '     <SUM_ISPOST_TEXT1>'
               || CHR (13)
               || CHR (10)
               || '     <SUM_ISPOST_TEXT2>'
               || CHR (13)
               || CHR (10)
               || '  <SUM_TEXT1>'
               || CHR (13)
               || CHR (10)
               || '  <SUM_TEXT2>'
               || CHR (13)
               || CHR (10)
               || '              '
               || CHR (13)
               || CHR (10)
               || '  ВIДПОВIДАЛЬНИЙ ПРАЦIВНИК          ВIДПОВIДАЛЬНИЙ ПРАЦIВНИК'
               || CHR (13)
               || CHR (10)
               || '  УПОВНОВАЖЕНОГО ОРГАНУ             УПОВНОВАЖЕНОЇ ОРГАНІЗАЦІЇ   '
               || CHR (13)
               || CHR (10)
               || '  ___________<MAIN_PIB>  __________________________'
               || CHR (13)
               || CHR (10)
               || '         (ПIДПИС,ПIБ)                     (ПIДПИС,ПIБ)'
               || CHR (13)
               || CHR (10)
               || CHR (13)
               || CHR (10)
               || '               М.П.                          ШТАМП   '
               || CHR (13)
               || CHR (10)
               || '                                             '
               || CHR (13)
               || CHR (10);

        TYPE t_temp_record IS RECORD
        (
            prs_index           uss_ndi.v_ndi_post_office.npo_index%TYPE,
            ncn_name            uss_ndi.v_ndi_comm_node.ncn_name%TYPE,
            pp_day              INTEGER,
            pp_sum              pr_sheet.prs_sum%TYPE,
            row_count           INTEGER,
            is_payed_on_post    INTEGER,
            rn_ind              INTEGER
        );

        TYPE t_temp_table IS TABLE OF t_temp_record
            INDEX BY PLS_INTEGER;

        l_rep               t_temp_table;

        CURSOR c_rep (p_max_row payroll.pr_pc_cnt%TYPE--p_is_use_limit payroll.psp_is_use_limit%type,
                                                      --p_org_id       v_opfu.org_id%type,
                                                      --p_per_date     nsi_period.per_date%type
                                                      )
        IS
              SELECT NVL (prs_index, 0)                       AS prs_index,
                     ncn_name,
                     TO_CHAR (EXTRACT (DAY FROM pp_date))     pp_day,
                     SUM (prs_sum)                            prs_sum,
                     COUNT (DISTINCT prs_pc)                  row_count,
                     is_payed_on_post,
                     rn_ind
                FROM (SELECT prs_index,
                             prs_pc,
                             -- #86654  upper(coalesce(ncn_sname,' '))
                             ' '
                                 ncn_name,
                             /*case psp.pr_tp when 'A'
                               then case when psp.psp_is_use_ppa_day_pay='F' then trunc(pp_date,'mm')+psp.psp_day_pay-1 else greatest(trunc(pp_date,'mm')+psp.psp_day_pay-1, pp_date) end
                               else pp_date
                             end*/
                             s.prs_pay_dt
                                 pp_date,
                             prs_sum,
                             -- case coalesce(adr_pp_tp,'D') when 'D' then 0 else 1 end as is_payed_on_post,
                             CASE WHEN s.prs_nd > 0 THEN 0 ELSE 1 END
                                 AS is_payed_on_post,
                             prs_num
                                 rn_ind
                        FROM payroll pr
                             INNER JOIN pr_sheet s ON prs_pr = pr_id
                             INNER JOIN v_opfu o ON org_id = pr.com_org
                             JOIN uss_ndi.v_ndi_payment_codes c
                                 ON c.npc_id = pr.pr_npc
                       -- #86654  left join uss_ndi.v_ndi_post_office pi on pi.npo_index = /*s.prs_index*/lpad(s.prs_index, 5, '0')  and pi.history_status = 'A'
                       --   #85038  npo_org не заповнене  and pi.npo_org = pr.com_org
                       -- #86654  left join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A'
                       WHERE     pr_id = p_pr_id
                             AND pr_pay_tp = 'POST'
                             AND prs_sum                                /*!=*/
                                         > 0
                             AND prs_st NOT IN ('PP')
                             AND PRS_tp IN ('PP')  -- #85724 -  Виплата поштою
                                                 ) t
            GROUP BY NVL (prs_index, 0),
                     ncn_name,
                     pp_date,
                     is_payed_on_post,
                     rn_ind
            ORDER BY NVL (prs_index, 0), pp_date, rn_ind;

        --
        v_rep               c_rep%ROWTYPE;

        --StartNewPage
        PROCEDURE StartNewPage
        IS
        BEGIN
            l_buff :=
                   ' ----------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF l_row_num = 0
            THEN                                              -- if first page
                l_buff := REPLACE (l_buff, '', '');
            END IF;

            l_org_num := l_org_num + 1;
            l_index_num := l_index_num + 1;
            l_row_num := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --PageHeader
        PROCEDURE PageHeader (
            p_ind_ind     IN uss_ndi.v_ndi_post_office.npo_index%TYPE,
            p_cntr_name   IN uss_ndi.v_ndi_comm_node.ncn_name%TYPE)
        IS
        BEGIN
            --l_buff := l_page_header;
            --l_rn_rep:=0;
            --l_sum_tab:=0;
            l_index_num := 1;
            l_count_ind := 0;
            l_sum_ind := 0;
            l_sum_ind_ispost := 0;
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (l_page_header,
                                     '<ORG_NUM>',
                                     PrintRight (TO_CHAR (l_org_num), 6)),
                            '<IND_NUM>',
                            PrintRight (TO_CHAR (l_index_num), 5)),
                        '<IND_IND>',
                        PrintRight (
                            LPAD (TRIM (TO_CHAR (p_ind_ind, '99990')),
                                  5,
                                  '0'),
                            6)),
                    '<CNTR_NAME>',
                    PrintRight (SUBSTR (p_cntr_name, 1, 38), 38));

            --    l_buff := REPLACE(l_buff, '<NPC_NAME>', PrintLeft(l_npc_name,30));  --  #83697
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME>',
                    PrintLeft (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                1,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 60),
                                       ' ',
                                       -1))),
                        60));                       --PrintLeft(l_npc_name,30)
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME2>',
                    PrintRight (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 60),
                                       ' ',
                                       -1),
                                30)),
                        30));

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 17;
        END;

        --
        PROCEDURE TabHeader (
            p_ind_ind     IN uss_ndi.v_ndi_post_office.npo_index%TYPE,
            p_cntr_name   IN uss_ndi.v_ndi_comm_node.ncn_name%TYPE)
        IS
        BEGIN
            --l_buff := l_page_header;
            --l_rn_rep:=0;
            --l_sum_tab:=0;
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (l_tab_header,
                                     '<ORG_NUM>',
                                     PrintRight (TO_CHAR (l_org_num), 6)),
                            '<IND_NUM>',
                            PrintRight (TO_CHAR (l_index_num), 5)),
                        '<IND_IND>',
                        PrintRight (
                            LPAD (TRIM (TO_CHAR (p_ind_ind, '99990')),
                                  5,
                                  '0'),
                            6)),
                    '<CNTR_NAME>',
                    PrintCenter (SUBSTR (p_cntr_name, 1, 23), 23));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 5;
        END;

        --
        PROCEDURE TabBody (p_pp_day             IN VARCHAR2,
                           p_rn_ind             IN NUMBER,
                           p_row_count          IN NUMBER,
                           p_pp_sum             IN NUMBER,
                           p_is_payed_on_post   IN INTEGER)
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                l_tab_body,
                                '<PP_DAY>',
                                PrintRight (TRIM (TO_CHAR (p_pp_day, '90')),
                                            2)),
                            '<RN_IND>',
                            PrintRight (TRIM (TO_CHAR (p_rn_ind, '9999990')),
                                        7)),
                        '<ROW_COUNT>',
                        PrintRight (TO_CHAR (p_row_count), 7)),
                    '<PP_SUM>',
                    PrintRight (
                        TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '99999990.00')),
                        11));
            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            l_sum_ind := l_sum_ind + ROUND (p_pp_sum, 2);
            l_count_tab := l_count_tab + p_row_count;
            l_count_ind := l_count_ind + p_row_count;
            l_row_day := p_pp_day;

            IF p_is_payed_on_post = 1
            THEN
                l_sum_ind_ispost := l_sum_ind_ispost + ROUND (p_pp_sum, 2);
            END IF;

            l_row_num := l_row_num + 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE TabFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        l_tab_footer,
                        '<ROW_COUNT_TAB>',
                        PrintRight (TRIM (TO_CHAR (l_count_tab, '9999990')),
                                    7)),
                    '<PP_SUM_TAB>',
                    PrintRight (
                        TRIM (TO_CHAR (ROUND (l_sum_tab, 2), '99999990.00')),
                        11));
            l_sum_tab := 0;
            l_count_tab := 0;
            l_row_num := l_row_num + 3;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE PageFooter
        IS
            l_sum_text          VARCHAR2 (255);
            l_sum_ispost_text   VARCHAR2 (255);
        BEGIN
            l_sum_text := 'СУМА ' || UPPER (sum_to_text (l_sum_ind));
            l_sum_ispost_text := UPPER (sum_to_text (l_sum_ind_ispost));
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                l_page_footer,
                                                '<SUM_TEXT1>',
                                                PrintLeft (
                                                    SUBSTR (l_sum_text,
                                                            1,
                                                            57),
                                                    57)),
                                            '<SUM_TEXT2>',
                                            PrintLeft (
                                                SUBSTR (l_sum_text, 58, 57),
                                                57)),
                                        '<SUM_ISPOST_TEXT1>',
                                        PrintLeft (
                                            SUBSTR (l_sum_ispost_text, 1, 54),
                                            54)),
                                    '<SUM_ISPOST_TEXT2>',
                                    PrintLeft (
                                        SUBSTR (l_sum_ispost_text, 55, 54),
                                        54)),
                                '<COUNT_IND>',
                                PrintRight (
                                    TRIM (TO_CHAR (l_count_ind, '9999990')),
                                    7)),
                            '<SUM_IND_ISPOST>',
                            PrintRight (
                                TRIM (
                                    TO_CHAR (ROUND (l_sum_ind_ispost, 2),
                                             '9999999990.00')),
                                14)),
                        '<SUM_IND>',
                        PrintRight (
                            TRIM (
                                TO_CHAR (ROUND (l_sum_ind, 2),
                                         '9999999990.00')),
                            14)),
                    '<MAIN_PIB>',
                    PrintLeft (SUBSTR (''             /*tools.GetCurrUserPIB*/
                                         , 1, 20), 20));
            l_row_num := l_row_num + 17;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT npc_name
          INTO l_npc_name
          FROM payroll JOIN uss_ndi.v_ndi_payment_codes c ON npc_id = pr_npc
         WHERE pr_id = p_pr_id;

        FOR r
            IN (SELECT --lpad(to_char(pr_start_dt),2,'0')||to_char(per_date,'.mm.yyyy') psp_start_dt,
  --lpad(to_char(pr_stop_dt),2,'0')||to_char(per_date,'.mm.yyyy') psp_stop_dt,
                      c_per_start || '.' || TO_CHAR (pr.pr_start_dt, 'mm.yyyy')
                          AS pr_start_dt,
                      c_per_stop || '.' || TO_CHAR (pr.pr_start_dt, 'mm.yyyy')
                          AS pr_stop_dt,
                      --upper(get_org_sname(org_name)) opfu_name,
                      UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                          opfu_name,           --  #89720 Виправити назву УСЗН
                      TO_CHAR (pr_start_dt, 'yyyy')
                          per_year,
                      pr_start_dt
                          AS per_date,
                      UPPER (
                          TO_CHAR (pr_start_dt,
                                   'month',
                                   'nls_date_language = UKRAINIAN'))
                          per_month,
                      --/*pr_per_num*/  l_per_num per_num,
                      c.npc_code
                          AS pr_tp,
                      org_code,
                      'F'
                          pr_is_use_limit,
                      org_id,
                      CASE
                          WHEN COALESCE (pr_pc_cnt, 0) < 1 THEN 20 --ikis_ppvp.ikis_ppvp_prm_utl.GetParamAsNumber('MAX_REPORT_ROW_B1M', per_date)
                          ELSE pr_pc_cnt
                      END
                          max_report_row
                 FROM payroll pr
                      JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr_npc
                      JOIN v_opfu op ON pr.com_org = org_id
                      LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                          ON     dpp.dpp_org = op.org_id
                             AND dpp.dpp_tp = 'OSZN'
                             AND dpp.history_status = 'A'           --  #89720
                WHERE     pr_id = p_pr_id
                      AND pr.com_org = org_id
                      AND c.npc_id = pr_npc)
        LOOP
            OPEN c_rep (r.max_report_row /*,r.pr_is_use_limit,r.org_id,r.per_date*/
                                        );

            FETCH c_rep BULK COLLECT INTO l_rep;

            CLOSE c_rep;

            l_count := l_count + l_rep.COUNT;

            --raise_application_error(-20000, 'l_count = '||l_count);
            IF l_rep.COUNT <> 0
            THEN
                --
                l_page_header := l_page_header_tmp;
                l_tab_header := l_tab_header_tmp;
                l_page_header :=
                    REPLACE (l_page_header,
                             '<PER_MONTH>',
                             PrintLeft (r.per_month, 8));
                l_page_header :=
                    REPLACE (l_page_header,
                             '<PER_YEAR>',
                             PrintLeft (r.per_year || ' Р.', 7));
                l_page_header :=
                    REPLACE (l_page_header,
                             '<OPFU_NAME>',
                             PrintLeft (SUBSTR (r.opfu_name, 1,         /*48*/
                                                                44), 44 /*48*/
                                                                       ));
                l_page_header :=
                    REPLACE (l_page_header, '<PSP_START_DT>', r.pr_start_dt);
                l_page_header :=
                    REPLACE (l_page_header, '<PSP_STOP_DT>', r.pr_stop_dt);
                l_page_header :=
                    REPLACE (l_page_header,
                             '<PSP_TP>',                         /*PrintLeft*/
                             PrintRight (r.pr_tp            /*|| l_a_pr_name*/
                                                , 2));
                l_tab_header :=
                    REPLACE (l_tab_header,
                             '<OPFU_NAME>',
                             PrintLeft (SUBSTR (r.opfu_name, 1, 42), 42));

                --
                FOR i IN l_rep.FIRST .. l_rep.LAST
                LOOP
                    IF l_row_num >= l_page_height
                    THEN
                        StartNewPage;
                        TabHeader (p_ind_ind     => l_prs_index /*l_rep(i).prs_index*/
                                                               ,
                                   p_cntr_name   => l_ncn_name /*l_rep(i).ncn_name*/
                                                              );
                    END IF;

                    IF    l_rep (i).prs_index != l_prs_index
                       OR l_org_id <> r.org_id
                    THEN
                        IF                  /*l_rep(i).pp_day!=l_row_day and*/
                           l_row_day != 0
                        THEN
                            IF l_row_num >= l_page_height - 20
                            THEN
                                StartNewPage;
                            END IF;

                            IF l_org_id = r.org_id
                            THEN
                                TabFooter;
                                PageFooter;
                            END IF;
                        END IF;

                        StartNewPage;
                        PageHeader (
                            p_ind_ind     => NVL (l_rep (i).prs_index, 0),
                            p_cntr_name   => l_rep (i).ncn_name);
                    ELSE
                        IF l_rep (i).pp_day != l_row_day AND l_row_day != 0
                        THEN
                            TabFooter;
                        END IF;
                    END IF;

                    TabBody (
                        p_pp_day             => l_rep (i).pp_day,
                        p_rn_ind             => l_rep (i).rn_ind,
                        p_row_count          => l_rep (i).row_count,
                        p_pp_sum             => l_rep (i).pp_sum,
                        p_is_payed_on_post   => l_rep (i).is_payed_on_post);

                    l_prs_index := NVL (l_rep (i).prs_index, 0);
                    l_ncn_name := NVL (l_rep (i).ncn_name, ' ');
                    l_org_id := r.org_id;
                END LOOP;

                IF l_row_num >= l_page_height - 20
                THEN
                    StartNewPage;
                END IF;

                TabFooter;
                PageFooter;
            END IF;

            l_org_id := r.org_id;
        END LOOP;

        IF l_count = 0
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973

        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "Реєстр відомостей на виплату форма B4-M"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Реєстр відомостей на виплату форма B4-M": '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPaymentB4M;

    PROCEDURE BuildPaymentB5M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd  in v_asopd2opfu.asop_org%type,
                               p_rpt     IN OUT NOCOPY BLOB)
    IS
        p_asopd              VARCHAR2 (10) := '';
        l_buff               VARCHAR2 (32767);
        l_row_num            NUMBER := 0;
        l_page_width         NUMBER := 63;
        l_page_height        NUMBER := 67;           -- CT_MAX_REPORT_ROW_TXT;
        --
        l_org_code           v_opfu.org_code%TYPE;
        l_org_rn             NUMBER := 1;
        l_org_doc_count      NUMBER := 0;
        l_org_person_count   NUMBER := 0;
        l_org_pp_sum         NUMBER := 0;
        l_org_ispost_sum     NUMBER := 0;
        l_count              INTEGER := 0;
        l_org_cnt            INTEGER := 0;
        l_ncn_id             INTEGER := 0;
        l_a_pr_name          VARCHAR2 (100);
        -- l_per_num   number := 1;
        l_npc_name           VARCHAR2 (100);

        l_page_header_tmp    VARCHAR2 (32767)
            :=    '                                              '
               || CHR (13)
               || CHR (10)
               || '                  С У П Р О В I Д Н И Й    О П И С  №'
               || CHR (13)
               || CHR (10)
               || '                      BIДOMOCTEЙ НА ВИПЛАТУ ГРОШОВОЇ'
               || CHR (13)
               || CHR (10)
               || ' <NPC_NAME> '
               || CHR (13)
               || CHR (10)
               || '  <NPC_NAME2> ЗА <PER_MONTH> <PER_YEAR>'
               || CHR (13)
               || CHR (10)
               || '   HA ПEPIOД З <PSP_START_DT> ПO <PSP_STOP_DT>   '
               ||                                       /* chr(13) || chr(10) ||*/
                  ' ТИП ВIДОМОСТI  <PSP_TP>'
               || CHR (13)
               || CHR (10)
               || ' ВИПЛАТНИЙ ОБ''ЄКТ <CNTR_NAME>'
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME>'
               || CHR (13)
               || CHR (10)
               || CASE
                      WHEN p_asopd IS NOT NULL
                      THEN
                             PrintCenter (p_asopd, l_page_width)
                          || CHR (13)
                          || CHR (10)
                  END
               || '   +---+---------+-----------+-----------+------------+-----+'
               || CHR (13)
               || CHR (10)
               || '   ¦   ¦НАЙМ ВИПЛ¦           ¦           ¦  СУМА СОЦ  ¦     ¦'
               || CHR (13)
               || CHR (10)
               || '   ¦ N ¦ ОБ`ЄКТА ¦ КIЛЬКIСТЬ ¦ КIЛЬКIСТЬ ¦  ДОПОМ ЗА  ¦ПРИМI¦'
               || CHR (13)
               || CHR (10)
               || '   ¦З/П¦         ¦BIДOMOCTЕЙ ¦ОДЕРЖУВАЧIВ¦ВIДОМОСТЯМИ ¦ТКА  ¦'
               || CHR (13)
               || CHR (10)
               || '   +---+---------+-----------+-----------+------------+-----+'
               || CHR (13)
               || CHR (10)
               || '   ¦ 1 ¦    2    ¦     3     ¦     4     ¦      5     ¦  6  ¦'
               || CHR (13)
               || CHR (10)
               || '   +---+---------+-----------+-----------+------------+-----+'
               || CHR (13)
               || CHR (10);
        l_page_header        VARCHAR2 (32767) := l_page_header_tmp;
        l_tab_header         VARCHAR2 (32767)
            :=    '   +---+---------+-----------+-----------+------------+-----+'
               || CHR (13)
               || CHR (10)
               || '   ¦ 1 ¦    2    ¦     3     ¦     4     ¦      5     ¦  6  ¦'
               || CHR (13)
               || CHR (10)
               || '   +---+---------+-----------+-----------+------------+-----+'
               || CHR (13)
               || CHR (10);
        l_tab_body           VARCHAR2 (32767)
            :=    '   ¦<ORG_RN>   <IND_IND>   <TAB_DOC_COUNT>      <TAB_PERSON_COUNT>   <TAB_PP_SUM>      ¦'
               || CHR (13)
               || CHR (10);
        l_tab_footer         VARCHAR2 (32767)
            :=    '   +--------------------------------------------------------+'
               || CHR (13)
               || CHR (10);
        l_page_footer        VARCHAR2 (32767)
            :=    '    У С Ь О Г O    <ORG_DOC_COUNT>      <ORG_PERSON_COUNT> <ORG_PP_SUM>'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '    <ORG_SUM_TEXT1>'
               || CHR (13)
               || CHR (10)
               || '    <ORG_SUM_TEXT2>'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '          В ТОМУ ЧИСЛI ЗА ВIДОМОСТЯМИ З ВIДМIТКОЮ `ДЛЯ ВИПЛАТИ'
               || CHR (13)
               || CHR (10)
               || '          В КАСI`                               <ORG_ISPOST_SUM>'
               || CHR (13)
               || CHR (10)
               || '          <ORG_ISPOST_SUM_TEXT1>'
               || CHR (13)
               || CHR (10)
               || '          <ORG_ISPOST_SUM_TEXT2>'
               || CHR (13)
               || CHR (10)
               || '   --------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               ||                                               -- io 20221117
                  '    ВIДП. ПРАЦIВНИК УПОВН. ОРГАНУ______________<MAIN_PIB>'
               || CHR (13)
               || CHR (10)
               || '                                          (ПIДПИС,ПIБ)'
               || CHR (13)
               || CHR (10)
               || '                                              М.П.'
               || CHR (13)
               || CHR (10)
               || '   --------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               ||                                               -- io 20221117
                  '    ВIДОМОСТI ВIДПРАВЛЕНО _____________________(ДАТА)'
               || CHR (13)
               || CHR (10)
               || '    ____________________________________________(ПIДПИС, ПIБ)'
               || CHR (13)
               || CHR (10)
               || '    ОТРИМАНО_____________ ВIДОМОСТЕЙ'
               || CHR (13)
               || CHR (10)
               || '    НА СУМУ ____________________________________'
               || CHR (13)
               || CHR (10)
               || '    ДАТА ОТРИМАННЯ_____________'
               || CHR (13)
               || CHR (10)
               || '    ОТРИМАНІ ВIДОМОСТI ПЕРЕВIРЕНО__________________'
               || CHR (13)
               || CHR (10)
               || '    ВІДП. ПРАЦІВНИК                                              '
               || CHR (13)
               || CHR (10)
               || '    УПОВН. ОРГАНІЗАЦІЇ___________________________________________'
               || CHR (13)
               || CHR (10)
               || '                                         (ПIДПИС, ПIБ)'
               || CHR (13)
               || CHR (10)
               || '                 ШТАМП       '
               || CHR (13)
               || CHR (10);

        CURSOR c_rep (p_max_row payroll.pr_pc_cnt%TYPE /*,
                  p_is_use_limit payroll.psp_is_use_limit%type,
                  p_org_id       v_opfu.org_id%type,
                  p_per_date     nsi_period.per_date%type*/
                                                      )
        IS
              SELECT NVL (prs_index, 0)
                         AS prs_index,
                     ncn_name,
                     SUM (prs_sum)
                         prs_sum,
                     COUNT (                                             /*1*/
                            DISTINCT prs_pc || '#' || rn_ind)
                         person_count, -- 1+ запис по 1 справі + в різних списках
                     /*max(rn_ind)*/
                     COUNT (DISTINCT rn_ind)
                         doc_count,                      -- #93043 io 20231026
                     SUM (
                         CASE WHEN is_payed_on_post = 1 THEN prs_sum ELSE 0 END)
                         org_ispost_sum,
                     ncn_id
                FROM (SELECT prs_index,
                             1
                                 AS ncn_id,
                             prs_pc,
                             -- #86654  upper(coalesce(cn.ncn_sname,' '))
                             ' '
                                 AS ncn_name,
                             s.prs_pay_dt
                                 pp_date,
                             prs_sum,
                             --case coalesce(adr_pp_tp,'D') when 'D' then 0 else 1 end is_payed_on_post,
                             CASE WHEN s.prs_nd > 0 THEN 0 ELSE 1 END
                                 AS is_payed_on_post,
                             prs_num
                                 rn_ind
                        FROM payroll pr
                             INNER JOIN pr_sheet s ON prs_pr = pr_id
                             INNER JOIN v_opfu o ON org_id = pr.com_org
                             JOIN uss_ndi.v_ndi_payment_codes c
                                 ON c.npc_id = pr.pr_npc
                       -- #86654 left join uss_ndi.v_ndi_post_office pi on pi.npo_index = /*s.prs_index*/lpad(s.prs_index, 5, '0') and pi.history_status = 'A'
                       --   #85038  npo_org не заповнене  and pi.npo_org = pr.com_org
                       -- #86654  left join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A'
                       WHERE     pr_id = p_pr_id
                             AND pr_pay_tp = 'POST'
                             AND prs_sum                                /*!=*/
                                         > 0
                             AND prs_st NOT IN ('PP')
                             AND PRS_tp IN ('PP') -- #85724 --  Виплата поштою
                                                 ) t
            GROUP BY prs_index, ncn_name, ncn_id
            ORDER BY ncn_id, prs_index;

        --
        v_rep                c_rep%ROWTYPE;

        --StartNewPage
        PROCEDURE StartNewPage
        IS
        BEGIN
            l_buff :=
                   ' --------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF l_row_num = 0
            THEN                                              -- if first page
                l_buff := REPLACE (l_buff, '', '');
            END IF;

            l_row_num := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --PageHeader
        PROCEDURE PageHeader (
            p_cntr_name   IN uss_ndi.v_ndi_comm_node.ncn_name%TYPE)
        IS
        BEGIN
            l_buff :=
                REPLACE (l_page_header,
                         '<CNTR_NAME>', /*PrintCenter(substr(p_cntr_name,1,l_page_width-1),l_page_width-1)*/
                         PrintRight (p_cntr_name, 42));
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME>',
                    PrintLeft (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                1,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 60),
                                       ' ',
                                       -1))),
                        60));                       --PrintLeft(l_npc_name,30)
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME2>',
                    PrintRight (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 60),
                                       ' ',
                                       -1),
                                30)),
                        30));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 16;
        END;

        --
        PROCEDURE TabHeader
        IS
        BEGIN
            l_buff := l_tab_header;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 3;
        END;

        --
        PROCEDURE TabBody (
            p_ind_ind          IN uss_ndi.v_ndi_post_office.npo_index%TYPE,
            p_doc_count        IN NUMBER,
            p_person_count     IN NUMBER,
            p_pp_sum           IN NUMBER,
            p_org_ispost_sum   IN NUMBER)
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    l_tab_body,
                                    '<ORG_RN>',
                                    PrintRight (
                                        TRIM (TO_CHAR (l_org_rn, '990')),
                                        3)),
                                '<IND_IND>',
                                PrintRight (
                                    LPAD (
                                        TRIM (TO_CHAR (p_ind_ind, '99990')),
                                        5,
                                        '0'),
                                    6)),
                            '<TAB_DOC_COUNT>',
                            PrintRight (
                                TRIM (TO_CHAR (p_doc_count, '9999990')),
                                7)),
                        '<TAB_PERSON_COUNT>',
                        PrintRight (
                            TRIM (TO_CHAR (p_person_count, '9999990')),
                            7)),
                    '<TAB_PP_SUM>',
                    PrintRight (
                        TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '999999990.00')),
                        12));
            l_row_num := l_row_num + 1;
            l_org_rn := l_org_rn + 1;
            l_org_doc_count := l_org_doc_count + p_doc_count;
            l_org_person_count := l_org_person_count + p_person_count;
            l_org_pp_sum := l_org_pp_sum + p_pp_sum;
            l_org_ispost_sum := l_org_ispost_sum + p_org_ispost_sum;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE TabFooter
        IS
        BEGIN
            l_buff := l_tab_footer;
            l_row_num := l_row_num + 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE PageFooter
        IS
            l_org_sum_text          VARCHAR2 (255);
            l_org_ispost_sum_text   VARCHAR2 (255);
        BEGIN
            l_org_sum_text := UPPER (sum_to_text (l_org_pp_sum));
            l_org_ispost_sum_text := UPPER (sum_to_text (l_org_ispost_sum));
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                REPLACE (
                                                    l_page_footer,
                                                    '<ORG_SUM_TEXT1>',
                                                    PrintLeft (
                                                        SUBSTR (
                                                            l_org_sum_text,
                                                            1,
                                                            58),
                                                        58)),
                                                '<ORG_SUM_TEXT2>',
                                                PrintLeft (
                                                    SUBSTR (l_org_sum_text,
                                                            59,
                                                            58),
                                                    58)),
                                            '<ORG_ISPOST_SUM_TEXT1>',
                                            PrintLeft (
                                                SUBSTR (
                                                    l_org_ispost_sum_text,
                                                    1,
                                                    53),
                                                53)),
                                        '<ORG_ISPOST_SUM_TEXT2>',
                                        PrintLeft (
                                            SUBSTR (l_org_ispost_sum_text,
                                                    54,
                                                    53),
                                            53)),
                                    '<ORG_DOC_COUNT>',
                                    PrintRight (
                                        TRIM (
                                            TO_CHAR (l_org_doc_count,
                                                     '9999990')),
                                        7)),
                                '<ORG_PERSON_COUNT>',
                                PrintRight (
                                    TRIM (
                                        TO_CHAR (l_org_person_count,
                                                 '9999990')),
                                    7)),
                            '<ORG_ISPOST_SUM>',
                            PrintRight (
                                TRIM (
                                    TO_CHAR (ROUND (l_org_ispost_sum, 2),
                                             '9999999990.00')),
                                14)),
                        '<ORG_PP_SUM>',
                        PrintRight (
                            TRIM (
                                TO_CHAR (ROUND (l_org_pp_sum, 2),
                                         '9999999990.00')),
                            14)),
                    '<MAIN_PIB>',
                    PrintLeft (SUBSTR (''             /*tools.GetCurrUserPIB*/
                                         , 1, 18), 18));
            l_row_num := l_row_num + 17;
            l_org_doc_count := 0;
            l_org_person_count := 0;
            l_org_pp_sum := 0;
            l_org_ispost_sum := 0;
            l_org_rn := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT npc_name
          INTO l_npc_name
          FROM payroll JOIN uss_ndi.v_ndi_payment_codes c ON npc_id = pr_npc
         WHERE pr_id = p_pr_id;


        FOR r
            IN (SELECT --lpad(to_char(pr_start_dt),2,'0')||to_char(per_date,'.mm.yyyy') psp_start_dt,
  --lpad(to_char(pr_stop_dt),2,'0')||to_char(per_date,'.mm.yyyy') psp_stop_dt,
                      c_per_start || '.' || TO_CHAR (pr.pr_start_dt, 'mm.yyyy')
                          AS pr_start_dt,
                      c_per_stop || '.' || TO_CHAR (pr.pr_start_dt, 'mm.yyyy')
                          AS pr_stop_dt,
                      --upper(get_org_sname(org_name)) opfu_name,
                      UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                          opfu_name,           --  #89720 Виправити назву УСЗН
                      TO_CHAR (pr_start_dt, 'yyyy')
                          per_year,
                      pr_start_dt
                          AS per_date,
                      UPPER (
                          TO_CHAR (pr_start_dt,
                                   'month',
                                   'nls_date_language = UKRAINIAN'))
                          per_month,
                      /*                  (select count(1) from v_payroll p2
                                         where p2.pr_month = pr.pr_month
                                           and p2.com_org = pr.com_org
                                           and p2.pr_npc = pr.pr_npc
                                           and p2.pr_pay_tp = pr.pr_pay_tp
                                           and p2.pr_tp = pr.pr_tp
                                           and p2.pr_create_dt <= pr.pr_create_dt) as per_num,*/
                      c.npc_code
                          pr_tp,
                      org_code,
                      'F'
                          pr_is_use_limit,
                      org_id,
                      CASE
                          WHEN COALESCE (pr_pc_cnt, 0) < 1 THEN 20 --ikis_ppvp.ikis_ppvp_prm_utl.GetParamAsNumber('MAX_REPORT_ROW_B1M', per_date)
                          ELSE pr_pc_cnt
                      END
                          max_report_row
                 --          FROM payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
                 FROM payroll pr
                      JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr_npc
                      JOIN v_opfu op ON pr.com_org = org_id
                      LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                          ON     dpp.dpp_org = op.org_id
                             AND dpp.dpp_tp = 'OSZN'
                             AND dpp.history_status = 'A'           --  #89720
                WHERE     pr_id = p_pr_id
                      AND pr.com_org = org_id
                      AND c.npc_id = pr_npc)
        LOOP
            l_page_header := l_page_header_tmp;
            l_page_header :=
                REPLACE (l_page_header,
                         '<PER_MONTH>',
                         PrintLeft (r.per_month, 8));
            l_page_header :=
                REPLACE (l_page_header,
                         '<PER_YEAR>',
                         PrintLeft (r.per_year || ' Р.', 7));
            l_page_header :=
                REPLACE (
                    l_page_header,
                    '<OPFU_NAME>',
                    PrintCenter (SUBSTR (r.opfu_name, 1, l_page_width - 1),
                                 l_page_width - 1));
            l_page_header :=
                REPLACE (l_page_header, '<PSP_START_DT>', r.pr_start_dt);
            l_page_header :=
                REPLACE (l_page_header, '<PSP_STOP_DT>', r.pr_stop_dt);
            l_page_header :=
                REPLACE (l_page_header, '<PSP_TP>', PrintRight (r.pr_tp, 2 /*||l_a_pr_name,81*/
                                                                          ));
            --
            l_org_cnt := 0;

            FOR v_rep IN c_rep (r.max_report_row /*, r.psp_is_use_limit, r.org_id, r.per_date*/
                                                )
            LOOP
                IF l_row_num >= l_page_height - 1
                THEN
                    TabFooter;
                    StartNewPage;
                    TabHeader;
                END IF;

                IF    r.org_code != l_org_code
                   OR l_org_code IS NULL
                   OR v_rep.ncn_id <> l_ncn_id
                THEN
                    /*if l_row_num>0 then
                      TabFooter;
                    end if;*/
                    IF l_ncn_id <> 0
                    THEN
                        TabFooter;
                        PageFooter;
                    END IF;

                    StartNewPage;
                    PageHeader (p_cntr_name => v_rep.ncn_name);
                    l_org_code := r.org_code;
                    l_ncn_id := v_rep.ncn_id;
                END IF;

                TabBody (p_ind_ind          => v_rep.prs_index,
                         p_doc_count        => v_rep.doc_count,
                         p_person_count     => v_rep.person_count,
                         p_pp_sum           => v_rep.prs_sum,
                         p_org_ispost_sum   => v_rep.org_ispost_sum);
                l_org_cnt := l_org_cnt + 1;
            END LOOP;

            l_count := l_count + l_row_num;

            --if r.org_id = 26274 then
            --raise_application_error(-20000, 'l_org_cnt = '||l_org_cnt);
            --end if;
            IF l_org_cnt > 0
            THEN
                --raise_application_error(-20000, 'l_org_cnt = '||l_org_cnt);
                TabFooter;

                IF l_row_num >= l_page_height - 28
                THEN
                    StartNewPage;
                    TabHeader;
                    TabFooter;
                END IF;

                PageFooter;
            END IF;
        END LOOP;

        IF l_count = 0
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973

        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "Опис відомостей на виплату форма B5-M"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Опис відомостей на виплату форма B5-M": '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPaymentB5M;

    PROCEDURE BuildPaymentB6M (p_pr_id   IN            payroll.pr_id%TYPE,
                               --p_org_id in psp2org.com_org%type,
                               --p_asopd in psp2org.com_org%type,
                               p_rpt     IN OUT NOCOPY BLOB)
    IS
        l_com_org         INTEGER;
        l_pib_mode        INTEGER := 1;    -- прізвище+ініціали; 0 = повне ПІБ
        p_asopd           VARCHAR2 (10) := '';
        l_buff            VARCHAR2 (32767) := '';
        l_row_num         NUMBER := 0;
        l_a_pr_name       VARCHAR2 (100);
        --  l_per_num   number := 1;
        l_npc_name        VARCHAR2 (100);
        l_page_num        INTEGER := 0;
        --
        l_page_body_tmp   VARCHAR2 (32767)
            :=    '                                                                  ¦'
               || CHR (13)
               || CHR (10)
               || '                                                        АРК  <PAGE_NUM>  ¦'
               || CHR (13)
               || CHR (10)
               || '            П I Д С У М К О В А    В I Д О М I С Т Ь              ¦'
               || CHR (13)
               || CHR (10)
               || '      HA BИПЛATУ ПEHCIЙ ТА ДОПОМОГИ ЗА <PER_MONTH> МIСЯЦЬ <PER_YEAR> РIК   ¦'
               || CHR (13)
               || CHR (10)
               || '      ТИП ВIДОМОСТI <PSP_TP2>¦'
               || CHR (13)
               || CHR (10)
               || '      ВИПЛАТНИЙ ОБ''ЄКТ <IND_IND> ВIДДIЛЕННЯ ЗВ`ЯЗКУ                  ¦'
               || CHR (13)
               || CHR (10)
               || '      <CNTR_NAME>¦'
               || CHR (13)
               || CHR (10)
               || '      <OPFU_NAME>¦'
               || CHR (13)
               || CHR (10)
               || CASE
                      WHEN p_asopd IS NOT NULL
                      THEN
                          '      ' || p_asopd || CHR (13) || CHR (10)
                  END
               || '     +---+--------+-----------+-----------+-------------+         ¦'
               || CHR (13)
               || CHR (10)
               || '     ¦ N ¦        ¦ КIЛЬКIСТЬ ¦ КIЛЬКIСТЬ ¦    СУМА     ¦         ¦'
               || CHR (13)
               || CHR (10)
               || '     ¦П/П¦ ПЕРIОД ¦BIДOMOCTЕЙ ¦OДЕРЖУВАЧIВ¦ (ГРН.КОП)   ¦         ¦'
               || CHR (13)
               || CHR (10)
               || '     +---+--------+-----------+-----------+-------------+         ¦'
               || CHR (13)
               || CHR (10)
               || '     ¦ 1 ¦ <TAB_PERIOD>¦<TAB_DOC_COUNT>  ¦<TAB_PERSON_COUNT>  ¦<TAB_PP_SUM>¦         ¦'
               || CHR (13)
               || CHR (10)
               || '     +---+--------+-----------+-----------+-------------+         ¦'
               || CHR (13)
               || CHR (10)
               || '     ¦  ВСЬОГО     <TAB_DOC_COUNT>   <TAB_PERSON_COUNT>   <TAB_PP_SUM>¦         ¦'
               || CHR (13)
               || CHR (10)
               || '     +--------------------------------------------------+         ¦'
               || CHR (13)
               || CHR (10)
               || '                                                                  ¦'
               || CHR (13)
               || CHR (10)
               || '     ВІДП. ОСОБА ОСЗН  <MAIN_PIB>¦'
               || CHR (13)
               || CHR (10)
               || '     ВІДП. ПРАЦІВНИК                                              ¦'
               || CHR (13)
               || CHR (10)
               || '     УПОВН. ОРГАНІЗАЦІЇ <BUCH_PIB>¦'
               || CHR (13)
               || CHR (10)
               || ' ---------------------------------------------------------------- ¦'
               || CHR (13)
               || CHR (10)
               || '                                                                  ¦'
               || CHR (13)
               || CHR (10)
               || '                           З В I Т  (<PSP_TP> ТИП ВIДОМОСТI)            ¦'
               || CHR (13)
               || CHR (10)
               || '      ПРО BИПЛATУ ПEHCIЙ, ГР. ДОПОМОГИ ЗА <PER_MONTH> МIСЯЦЬ <PER_YEAR> РIК¦'
               || CHR (13)
               || CHR (10)
               || '      ВИПЛАТНИЙ ОБ''ЄКТ <IND_IND> ВIДДIЛЕННЯ ЗВ`ЯЗКУ                  ¦'
               || CHR (13)
               || CHR (10)
               || '      <CNTR_NAME>¦'
               || CHR (13)
               || CHR (10)
               || '      <OPFU_NAME>¦'
               || CHR (13)
               || CHR (10)
               || CASE
                      WHEN p_asopd IS NOT NULL
                      THEN
                          '      ' || p_asopd || CHR (13) || CHR (10)
                  END
               || ' ---+------------------+----------------+-----------------+-------¦'
               || CHR (13)
               || CHR (10)
               || ' №  ¦     НАРАХОВАНО   ¦   ВИПЛАЧЕНО    ¦   НЕ ВИПЛАЧЕНО  ¦К-ТЬ   ¦'
               || CHR (13)
               || CHR (10)
               || ' З/П+-----+------------+-----+----------+-----+-----------+ВIДРИВ.¦'
               || CHR (13)
               || CHR (10)
               || '    ¦ К-ТЬ¦   СУМА     ¦К-ТЬ ¦   СУМА   ¦ К-ТЬ¦    СУМА   ¦ТАЛОНIВ¦'
               || CHR (13)
               || CHR (10)
               || '    ¦ОДЕРЖ¦  ГРН.  ¦КОП¦ОДЕРЖ¦  ГРН ¦КОП¦ОДЕРЖ¦   ГРН ¦КОП¦       ¦'
               || CHR (13)
               || CHR (10)
               || ' ---+-----+--------+---+-----+------+---+-----+-------+---+-------¦'
               || CHR (13)
               || CHR (10)
               || '      УСЬОГО'
               || CHR (13)
               || CHR (10)
               || ' <TAB_RN>¦<TAB_PERSON_COUNT2>¦<TAB_PP_SUM_LEFT>¦<TAB_PP_SUM_RIGHT>¦     ¦      ¦   ¦     ¦       ¦   ¦       ¦'
               || CHR (13)
               || CHR (10)
               || ' ---+-----+--------+---+-----+------+---+-----+-------+---+-------¦'
               || CHR (13)
               || CHR (10)
               || '  ВИПЛАЧЕНО ______________________________________________________¦'
               || CHR (13)
               || CHR (10)
               || '                      ( СУМА СЛОВАМИ )                            ¦'
               || CHR (13)
               || CHR (10)
               || '  НЕ ВИПЛАЧЕНО____________________________________________________¦'
               || CHR (13)
               || CHR (10)
               || '                      ( СУМА СЛОВАМИ )                            ¦'
               || CHR (13)
               || CHR (10)
               || '  КЕРIВНИК ВИПЛАТНОГО ОБ`ЄКТА         ___________<MAIN_PIB_SHORT>¦'
               || CHR (13)
               || CHR (10)
               || '                                             (пiдпис, ПIБ)        ¦'
               || CHR (13)
               || CHR (10)
               || '  КОНТРОЛЮЮЧА ОСОБА ВИПЛАТНОГО ОБ`ЄКТА___________<BUCH_PIB_SHORT>¦'
               || CHR (13)
               || CHR (10)
               || '                                             (пiдпис, ПIБ)        ¦'
               || CHR (13)
               || CHR (10)
               || '                                                                  ¦'
               || CHR (13)
               || CHR (10)
               || '          ШТАМП                                                   ¦'
               || CHR (13)
               || CHR (10)
               || ' -----------------------------------------------------------------¦'
               || CHR (13)
               || CHR (10);
        l_page_body       VARCHAR2 (32767) := l_page_body_tmp;

        CURSOR c_rep (p_max_row payroll.pr_pc_cnt%TYPE /*,
                       p_is_use_limit payroll.psp_is_use_limit%type,
                       p_org_id       v_opfu.org_id%type,
                       p_per_date     nsi_period.per_date%type*/
                                                      )
        IS
              SELECT NVL (prs_index, 0)                           AS prs_index,
                     ncn_name,
                     SUM (prs_sum)                                prs_sum,
                     COUNT (DISTINCT prs_pc || '#' || rn_ind)     person_count,
                     MAX (rn_ind)                                 doc_count
                FROM (SELECT prs_index,
                             prs_pc,
                             -- #86654  upper(coalesce(ncn_sname,' '))
                             ' '
                                 AS ncn_name,
                             s.prs_pay_dt
                                 pp_date,
                             prs_sum,
                             --case coalesce(adr_pp_tp,'D') when 'D' then 0 else 1 end is_payed_on_post,
                             CASE WHEN s.prs_nd > 0 THEN 0 ELSE 1 END
                                 AS is_payed_on_post,
                             prs_num
                                 rn_ind
                        FROM payroll pr
                             INNER JOIN pr_sheet s ON prs_pr = pr_id
                             INNER JOIN v_opfu o ON org_id = pr.com_org
                             JOIN uss_ndi.v_ndi_payment_codes c
                                 ON c.npc_id = pr.pr_npc
                       -- #86654  left join uss_ndi.v_ndi_post_office pi on pi.npo_index = /*s.prs_index*/lpad(s.prs_index, 5, '0') and pi.history_status = 'A'
                       --   #85038  npo_org не заповнене  and pi.npo_org = pr.com_org
                       -- #86654  left join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A'
                       WHERE     pr_id = p_pr_id
                             AND pr_pay_tp = 'POST'
                             AND prs_sum                                /*!=*/
                                         > 0
                             AND prs_st NOT IN ('PP')
                             AND PRS_tp IN ('PP') -- #85724 --  Виплата поштою
                                                 ) t
            GROUP BY prs_index, ncn_name
            ORDER BY prs_index;

        --
        v_rep             c_rep%ROWTYPE;

        --
        PROCEDURE PageBody (
            p_ind_ind        IN uss_ndi.v_ndi_post_office.npo_index%TYPE,
            p_cntr_name      IN uss_ndi.v_ndi_comm_node.ncn_name%TYPE,
            p_doc_count      IN NUMBER,
            p_person_count   IN NUMBER,
            p_pp_sum         IN NUMBER)
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                REPLACE (
                                                    REPLACE (
                                                        REPLACE (
                                                            REPLACE (
                                                                REPLACE (
                                                                    REPLACE (
                                                                        l_page_body,
                                                                        '<CNTR_NAME>',
                                                                        PrintLeft (
                                                                            SUBSTR (
                                                                                p_cntr_name,
                                                                                1,
                                                                                60),
                                                                            60)),
                                                                    '<IND_IND>',
                                                                    PrintRight (
                                                                        LPAD (
                                                                            TRIM (
                                                                                TO_CHAR (
                                                                                    p_ind_ind,
                                                                                    '99990')),
                                                                            5,
                                                                            '0'),
                                                                        6)),
                                                                '<TAB_DOC_COUNT>',
                                                                PrintRight (
                                                                    TRIM (
                                                                        TO_CHAR (
                                                                            p_doc_count,
                                                                            '999999990')),
                                                                    9)),
                                                            '<TAB_PERSON_COUNT2>',
                                                            PrintRight (
                                                                TRIM (
                                                                    TO_CHAR (
                                                                        p_person_count,
                                                                        '99990')),
                                                                5)),
                                                        '<TAB_PERSON_COUNT>',
                                                        PrintRight (
                                                            TRIM (
                                                                TO_CHAR (
                                                                    p_person_count,
                                                                    '999999990')),
                                                            9)),
                                                    '<TAB_PP_SUM>',
                                                    PrintRight (
                                                        TRIM (
                                                            TO_CHAR (
                                                                ROUND (
                                                                    p_pp_sum,
                                                                    2),
                                                                '9999999990.00')),
                                                        13)),
                                                '<TAB_PP_SUM_LEFT>',
                                                PrintRight (
                                                    TRIM (
                                                        TO_CHAR (
                                                            TRUNC (
                                                                ROUND (
                                                                    p_pp_sum,
                                                                    2)),
                                                            '99999990')),
                                                    8)),
                                            '<TAB_PP_SUM_RIGHT>',
                                            PrintRight (
                                                LTRIM (
                                                    TO_CHAR (
                                                          ROUND (p_pp_sum, 2)
                                                        - TRUNC (
                                                              ROUND (
                                                                  p_pp_sum,
                                                                  2)),
                                                        '.99'),
                                                    ' .'),
                                                3)),
                                        '<TAB_RN>',
                                        PrintRight (
                                            TRIM (
                                                TO_CHAR (l_row_num + 1,
                                                         '990')),
                                            3)),
                                    '<MAIN_PIB>',
                                    PrintLeft (
                                        SUBSTR (                    /*tools.*/
                                            get_acc_setup_pib (0,
                                                               l_pib_mode,
                                                               l_com_org),
                                            1,
                                            43),
                                        43)), -- #97222 io 20240117 тимчасово, до установки глобального патча на пром
                                '<BUCH_PIB>',
                                PrintLeft (
                                    SUBSTR (                        /*tools.*/
                                        get_acc_setup_pib (1,
                                                           l_pib_mode,
                                                           l_com_org),
                                        1,
                                        42),
                                    42)),
                            '<MAIN_PIB_SHORT>',
                            PrintLeft ( /*substr(tools.get_acc_setup_pib(0, l_pib_mode, l_com_org),1,17)*/
                                       '', 17)), -- io 20240126 ПІБ керівника та бухгалтера - тільки в верхньому описі залишити
                        '<BUCH_PIB_SHORT>',
                        PrintLeft ( /*substr(tools.get_acc_setup_pib(1, l_pib_mode, l_com_org),1,17)*/
                                   '', 17)), -- io 20240126 ПІБ керівника та бухгалтера - тільки в верхньому описі залишити
                    '<PAGE_NUM>',
                    PrintRight (l_page_num, 3));

            IF l_row_num = 0
            THEN
                l_buff :=
                    REPLACE (
                        l_buff,
                        '                                                                  ',
                        ' -----------------------------------------------------------------');
            END IF;

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 1;
        END;
    --
    BEGIN
        SELECT npc_name, com_org
          INTO l_npc_name, l_com_org
          FROM payroll JOIN uss_ndi.v_ndi_payment_codes c ON npc_id = pr_npc
         WHERE pr_id = p_pr_id;

        --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));

        FOR r
            IN (SELECT ---replace(to_char(pr_start_dt,'09')||'-'||to_char(pr_stop_dt,'09'),' ','')
                       '04-25'
                           period,
                       pr_start_dt,
                       pr_stop_dt,
                       --upper(get_org_sname(org_name)) opfu_name,
                       UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                           opfu_name,          --  #89720 Виправити назву УСЗН
                       TO_CHAR (pr_start_dt, 'yyyy')
                           per_year,
                       pr_start_dt
                           AS per_date,
                       UPPER (
                           TO_CHAR (pr_start_dt,
                                    'month',
                                    'nls_date_language = UKRAINIAN'))
                           per_month,
                       /*                 (select count(1) from v_payroll p2
                                          where p2.pr_month = pr.pr_month
                                            and p2.com_org = pr.com_org
                                            and p2.pr_npc = pr.pr_npc
                                            and p2.pr_pay_tp = pr.pr_pay_tp
                                            and p2.pr_tp = pr.pr_tp
                                            and p2.pr_create_dt <= pr.pr_create_dt) as per_num,*/
                       c.npc_code
                           pr_tp,
                       org_code,
                       'F'
                           pr_is_use_limit,
                       org_id,
                       CASE
                           WHEN COALESCE (pr_pc_cnt, 0) < 1 THEN 20 --ikis_ppvp.ikis_ppvp_prm_utl.GetParamAsNumber('MAX_REPORT_ROW_B1M', per_date)
                           ELSE pr_pc_cnt
                       END
                           max_report_row
                  --FROM payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
                  FROM payroll  pr
                       JOIN uss_ndi.v_ndi_payment_codes c
                           ON c.npc_id = pr_npc
                       JOIN v_opfu op ON pr.com_org = org_id
                       LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                           ON     dpp.dpp_org = op.org_id
                              AND dpp.dpp_tp = 'OSZN'
                              AND dpp.history_status = 'A'          --  #89720
                 WHERE     pr_id = p_pr_id
                       AND pr.com_org = org_id
                       AND c.npc_id = pr_npc)
        LOOP
            l_page_body := l_page_body_tmp;
            l_page_body :=
                REPLACE (l_page_body,
                         '<PER_MONTH>',
                         PrintLeft (r.per_month, 8));
            l_page_body :=
                REPLACE (l_page_body,
                         '<PER_YEAR>',
                         PrintLeft (r.per_year, 4));
            l_page_body :=
                REPLACE (l_page_body,
                         '<OPFU_NAME>',
                         PrintLeft (SUBSTR (r.opfu_name, 1, 60), 60));
            l_page_body :=
                REPLACE (l_page_body,
                         '<TAB_PERIOD>',
                         PrintLeft (r.period, 7));
            l_page_body :=
                REPLACE (l_page_body, '<PSP_TP>', PrintRight (r.pr_tp, 2));
            l_page_body :=
                REPLACE (l_page_body,
                         '<PSP_TP2>',
                         PrintLeft (r.pr_tp || l_a_pr_name, 46));
            --
            l_page_num := 0;

            FOR v_rep IN c_rep (r.max_report_row /*, r.psp_is_use_limit, r.org_id, r.per_date*/
                                                )
            LOOP
                PageBody (p_ind_ind        => v_rep.prs_index,
                          p_cntr_name      => v_rep.ncn_name,
                          p_doc_count      => v_rep.doc_count,
                          p_person_count   => v_rep.person_count,
                          p_pp_sum         => v_rep.prs_sum);
            END LOOP;
        END LOOP;

        IF l_row_num = 0
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973

        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "Підсумкова відомість на виплату форма B6-M"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Підсумкова відомість на виплату форма B6-M": '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPaymentB6M;

    PROCEDURE BuildPaymentV02M19_Supr (
        p_pr_id   IN            payroll.pr_id%TYPE,
        -- p_org_id in psp2org.com_org%type,
        -- p_asopd  in v_asopd2opfu.asop_org%type,
        p_rpt     IN OUT NOCOPY BLOB)
    IS
        p_asopd            VARCHAR2 (10) := '';
        l_buff             VARCHAR2 (32760);
        l_pr_start_dt      payroll.pr_start_dt%TYPE;
        l_pr_stop_dt       payroll.pr_stop_dt%TYPE;
        l_opfu_name        v_opfu.ORG_NAME%TYPE;
        l_per_year         VARCHAR2 (50);          --nsi_period.per_year%TYPE;
        l_per_month        VARCHAR2 (50);         --nsi_period.per_month%TYPE;
        l_date_start       VARCHAR2 (10);
        l_date_stop        VARCHAR2 (10);
        l_a_pr_name        VARCHAR2 (100);
        l_per_num          NUMBER := 1;
        l_npc_name         VARCHAR2 (100);

        l_column_width     NUMBER := 52;
        l_column_height    NUMBER := 69;    ---  CT_MAX_REPORT_ROW_TXT; --106;

        l_header_tab       VARCHAR2 (32760)
            :=    ' ---------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                       V 0 2 M 1 9  '
               || CHR (13)
               || CHR (10)
               || '              СУПРОВІДНА ВІДОМІСТЬ                  '
               || CHR (13)
               || CHR (10)
               ||                                                                --НА ЗАРАХУВАННЯ
                  ' <NPC_NAME> '
               || CHR (13)
               || CHR (10)
               || ' <NPC_NAME2> ЗА <PER_MONTH> <PER_YEAR> Р.'
               || CHR (13)
               || CHR (10)
               || '       ЗА ПЕРІОД № <PER_NUM> З <DATE_START> ПО <DATE_STOP>'
               || CHR (13)
               || CHR (10)
               || ' ТИП ВІДОМОСТІ <VED_TP> '
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME>'
               || CHR (13)
               || CHR (10)
               || ' <OPFU_NAME2>'
               || CHR (13)
               || CHR (10)
               || --- #86057  case when p_asopd is not null then PrintCenter(' '||p_asopd, l_column_width) end || chr(13) || chr(10) ||
                  ' <PAGE_NUM>'
               || CHR (13)
               || CHR (10)
               || ' ---------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || ' ВІДДІЛЕННЯ : NN ВІДОМ.: КІЛЬКІСТЬ :     СУМА,      '
               || CHR (13)
               || CHR (10)
               || '  ЗВ''ЯЗКУ   :  (З-ПО)  :ОДЕРЖУВАЧІВ:   (ГРН.КОП.)   '
               || CHR (13)
               || CHR (10)
               || --'            :          :           :                ' || chr(13) || chr(10) ||
                  ' ---------------------------------------------------'
               || CHR (13)
               || CHR (10);
        l_comcntr_footer   VARCHAR2 (10000)
            :=    ' ---------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || ---  ' <NAME_CNTR>' || chr(13) || chr(10) ||
                  '   ВСЬОГО <DOC_CNTR> <CNT_CNTR> <SUM_CNTR>'
               || CHR (13)
               || CHR (10)
               || ' ---------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || ' '
               || CHR (13)
               || CHR (10)
               || ' ВИДАВ   ___________________________________________'
               || CHR (13)
               || CHR (10)
               || ' '
               || CHR (13)
               || CHR (10)
               || ' ОДЕРЖАВ ___________________________________________';

        l_page_num         NUMBER := 0;
        l_row_num          NUMBER := 0;

        l_comcntr_id       uss_ndi.v_ndi_comm_node.ncn_id%TYPE;
        l_prs_index        VARCHAR2 (6); --uss_ndi.v_ndi_post_office.npo_index%TYPE;
        l_npo_address      VARCHAR2 (250);        --;v_nsi_index.ind_adr%TYPE;
        l_comcntr_cnt      INT;
        l_comcntr_sum      pr_sheet.prs_sum%TYPE;
        l_comdoc_cnt       INT;
        --l_per_num      payroll.pr_per_num%TYPE;
        l_ved_tp           CHAR (20);
        l_comncn_name      uss_ndi.v_ndi_comm_node.ncn_name%TYPE;
        l_all_cnt          INT := 0;
        l_all_sum          pr_sheet.prs_sum%TYPE := 0;
        l_doc_cnt          INT;

        CURSOR c_rep (p_com_org payroll.com_org%TYPE)
        IS
              SELECT /* #86057 coalesce(npo_ncn, -1)*/
                     -1                                            npo_ncn,
                     COALESCE (prs_index, '-1')                    prs_index,
                     -- #86654 pi.npo_address,
                     MIN (prs_num)                                 min_doc_num,
                     MAX (prs_num)                                 max_doc_num,
                     COUNT (DISTINCT prs_num)                      pr_cnt, -- #93043 io 20231020
                     ' '                                           ncn_code,
                     /* #86057 coalesce(to_char(npo_ncn),'')||' '||ncn_sname*/
                     ' '                                           ncn_name, --substr(ncn_name,1,length(ncn_name)-5)
                     l_per_num                                     AS pr_per_num,
                     --psp_ved_tp,
                     COUNT (DISTINCT prs_pc || '#' || prs_num)     c,
                     SUM (prs_sum)                                 s
                FROM payroll pr JOIN pr_sheet s ON prs_pr = pr_id
               --join pensionfile on pnf_id=prs_pnf
               --join penslist on pnl_pnf=pnf_id  and pnl_st = 'S'
               --join address adr on adr.adr_pnf = pnf_id and adr.adr_history_st='A' and adr.adr_tp = 'P'
               -- #86654  left join uss_ndi.v_ndi_post_office pi on pi.npo_index = lpad(s.prs_index, 5, '0') and pi.history_status = 'A'
               --   #85038  npo_org не заповнене  and pi.npo_org = pr.com_org
               -- #86654  left join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A'
               WHERE     pr_id = p_pr_id
                     AND pr.COM_ORG = p_com_org
                     AND pr_pay_tp = 'POST'                 -- без видрахувань
                     AND prs_sum <> 0
                     AND prs_st NOT IN ('PP')
                     AND PRS_tp IN ('PP')
            GROUP BY                                              /*npo_ncn,*/
                     prs_index --, npo_address---#86057, ncn_code, ncn_sname -- , pr_per_num--, psp_ved_tp
            ORDER BY                                             /*ncn_code,*/
                     prs_index;

        v_rep              c_rep%ROWTYPE;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_row_num := 0;
        END;

        PROCEDURE PageScrool
        IS
            i   INT;
        BEGIN
            l_buff :=                                                /*null;*/
                      CHR (13) || CHR (10);

            /*FOR i IN 1.. l_column_height - l_row_num
            LOOP
              l_buff := l_buff || chr(13) || chr(10);
            END LOOP;*/
            IF l_row_num < l_column_height
            THEN
                l_buff := l_buff || CHR (12);
            END IF;

            IF l_buff IS NOT NULL
            THEN
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                    UTL_RAW.cast_to_raw (l_buff));
            END IF;
        END;

        PROCEDURE TabHeader (p_date_start   VARCHAR2,
                             p_date_stop    VARCHAR2,
                             p_opfu_name    v_opfu.ORG_NAME%TYPE,
                             p_per_num      NUMBER, -- payroll.pr_per_num%type,
                             p_ved_tp       VARCHAR2)
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (l_header_tab,
                                                 '<DATE_START>',
                                                 p_date_start),
                                        '<DATE_STOP>',
                                        p_date_stop),
                                    '<OPFU_NAME>',
                                    PrintCenter (p_opfu_name,
                                                 l_column_width - 1)),
                                '<OPFU_NAME2>',
                                PrintLeft (
                                    COALESCE (
                                        SUBSTR (p_opfu_name,
                                                l_column_width,
                                                l_column_width - 13),
                                        ' '),
                                    l_column_width - 12)),
                            '<PER_NUM>',
                            p_per_num),
                        '<VED_TP>',
                        p_ved_tp || l_a_pr_name),
                    '<PAGE_NUM>',
                    PrintRight ('АРКУШ N ' || l_page_num, l_column_width - 1));

            l_buff :=
                REPLACE (l_buff, '<PER_MONTH>', PrintLeft (l_per_month, 8));
            l_buff :=
                REPLACE (l_buff, '<PER_YEAR>', PrintLeft (l_per_year, 4));
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME>',
                    PrintLeft (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                1,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 50),
                                       ' ',
                                       -1))),
                        50));                     /*PrintLeft(l_npc_name,30)*/
            l_buff :=
                REPLACE (
                    l_buff,
                    '<NPC_NAME2>',                              /*PrintRight*/
                    PrintLeft (
                        TRIM (
                            SUBSTR (
                                l_npc_name,
                                INSTR (SUBSTR (l_npc_name || ' ', 1, 50),
                                       ' ',
                                       -1),
                                30)),
                        30));

            l_buff := CASE WHEN l_page_num > 1 THEN CHR (12) END || l_buff; -- io 20230918

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := 14;
        END;

        PROCEDURE ComCntrFooter (p_date_start   VARCHAR2,
                                 p_date_stop    VARCHAR2,
                                 p_opfu_name    v_opfu.ORG_NAME%TYPE,
                                 p_per_num      NUMBER, -- payroll.pr_per_num%type,
                                 p_ved_tp       VARCHAR2)
        IS
        BEGIN
            IF l_row_num + 7 > l_column_height
            THEN
                PageScrool;
                PageHeader;
                TabHeader (p_date_start,
                           p_date_stop,
                           p_opfu_name,
                           p_per_num,
                           p_ved_tp);
            END IF;

            l_row_num := l_row_num + 7;

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                l_comcntr_footer,
                                '<NAME_CNTR>',
                                PrintLeft (l_comncn_name, l_column_width - 1)),
                            '<DOC_CNTR>',
                            PrintRight (l_comdoc_cnt, 13)),
                        '<CNT_CNTR>',
                        PrintRight (l_comcntr_cnt, 11)),
                    '<SUM_CNTR>',
                    TO_CHAR (l_comcntr_sum, '999999999990.00'));

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_comcntr_cnt := 0;
            l_comcntr_sum := 0;
            l_comdoc_cnt := 0;
        END;
    BEGIN
        SELECT npc_name,
               TO_CHAR (pr_start_dt, 'yyyy')                     per_year,
               UPPER (
                   TO_CHAR (pr_start_dt,
                            'month',
                            'nls_date_language = UKRAINIAN'))    per_month
          INTO l_npc_name, l_per_year, l_per_month
          FROM payroll JOIN uss_ndi.v_ndi_payment_codes c ON npc_id = pr_npc
         WHERE pr_id = p_pr_id;

        FOR r
            IN (SELECT com_org,
                       pr_start_dt,
                       pr_stop_dt,
                       --upper(org_code||'-'||get_org_sname(org_name)/*org_name*/) opfu_name,
                       UPPER (
                              org_code
                           || '-'
                           || NVL (dpp.dpp_sname, get_org_sname (org_name)))
                           opfu_name,          --  #89720 Виправити назву УСЗН
                       TO_CHAR (pr_start_dt, 'yyyy')
                           per_year,
                       pr_start_dt
                           AS per_date,
                       UPPER (
                           TO_CHAR (pr_start_dt,
                                    'month',
                                    'nls_date_language = UKRAINIAN'))
                           per_month,
                       (SELECT COUNT (1)
                          FROM v_payroll p2
                         WHERE     p2.pr_month = pr.pr_month
                               AND p2.com_org = pr.com_org
                               AND p2.pr_npc = pr.pr_npc
                               AND p2.pr_pay_tp = pr.pr_pay_tp
                               --and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                               AND p2.pr_create_dt <= pr.pr_create_dt)
                           AS per_num,                           /*l_per_num*/
                       c.npc_code
                           AS ved_tp,      --decode(pr_tp, 'M', '1', 'A', '2')
                       org_code,
                       'F'
                           pr_is_use_limit,
                       org_id,
                       CASE
                           WHEN COALESCE (pr_pc_cnt, 0) < 1 THEN 20 --ikis_ppvp.ikis_ppvp_prm_utl.GetParamAsNumber('MAX_REPORT_ROW_B1M', per_date)
                           ELSE pr_pc_cnt
                       END
                           max_report_row
                  --FROM payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
                  FROM payroll  pr
                       JOIN uss_ndi.v_ndi_payment_codes c
                           ON c.npc_id = pr_npc
                       JOIN v_opfu op ON pr.com_org = org_id
                       LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                           ON     dpp.dpp_org = op.org_id
                              AND dpp.dpp_tp = 'OSZN'
                              AND dpp.history_status = 'A'          --  #89720
                 WHERE     pr_id = p_pr_id
                       AND pr.com_org = org_id
                       AND c.npc_id = pr_npc)
        LOOP
            l_date_start :=
                c_per_start || '.' || TO_CHAR (r.pr_start_dt, 'mm.yyyy'); --r.pr_start_dt;-- || '.' || lpad(r.per_month, 2, '0') || '.' || r.per_year;
            l_date_stop :=
                c_per_stop || '.' || TO_CHAR (r.pr_start_dt, 'mm.yyyy'); --r.pr_stop_dt;-- || '.' || lpad(r.per_month, 2, '0') || '.' || r.per_year;

            l_comcntr_id := 0;
            l_comcntr_cnt := 0;
            l_comcntr_sum := 0;
            l_comdoc_cnt := 0;

            PageHeader;
            TabHeader (l_date_start,
                       l_date_stop,
                       r.opfu_name,
                       r.per_num,
                       r.ved_tp);

            FOR v_rep IN c_rep (r.com_org)
            LOOP
                IF l_comcntr_id <> v_rep.npo_ncn
                THEN
                    IF l_comcntr_id <> 0
                    THEN
                        -- футер для отделения связи
                        ComCntrFooter (l_date_start,
                                       l_date_stop,
                                       r.opfu_name,
                                       r.per_num,
                                       r.ved_tp);
                        PageScrool;
                        PageHeader;
                        TabHeader (l_date_start,
                                   l_date_stop,
                                   r.opfu_name,
                                   r.per_num,
                                   r.ved_tp);
                    END IF;

                    l_comcntr_id := v_rep.npo_ncn;
                    l_comncn_name := v_rep.ncn_name;
                END IF;

                l_buff :=
                       ' '
                    || PrintLeft (LPAD (v_rep.prs_index, 5, '0'), 14)
                    || ' '
                    || PrintRight ( /*v_rep.min_doc_num||'-'||v_rep.max_doc_num*/
                                   v_rep.pr_cnt, 7)
                    || ' '
                    ||                                   -- #93043 io 20231020
                       PrintRight (v_rep.c, 11)
                    || ' '
                    || TO_CHAR (ROUND (v_rep.s, 2), '999999999990.00')
                    || ' '
                    || CHR (13)
                    || CHR (10);

                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                    UTL_RAW.cast_to_raw (l_buff));
                l_row_num := l_row_num + 1;

                IF l_row_num + 1 > l_column_height
                THEN
                    PageScrool;
                    PageHeader;
                    TabHeader (l_date_start,
                               l_date_stop,
                               r.opfu_name,
                               r.per_num,
                               r.ved_tp);
                END IF;

                l_comcntr_cnt := l_comcntr_cnt + v_rep.c;
                l_comcntr_sum := l_comcntr_sum + v_rep.s;
                l_comdoc_cnt := l_comdoc_cnt + v_rep.max_doc_num;
            END LOOP;

            -- футер для отделения связи
            ComCntrFooter (l_date_start,
                           l_date_stop,
                           r.opfu_name,
                           r.per_num,
                           r.ved_tp);
            PageScrool;
        END LOOP;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
    --add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Супровідна відомість (віділення пошти)": '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Формуємо архів з файлами друкованих форм на пошту по ВВ
    PROCEDURE BuildPostFile (p_pr_list    IN            VARCHAR2,
                             p_rpt        IN OUT NOCOPY BLOB,
                             p_rpt_name      OUT        VARCHAR2)
    IS
        p_asopd      VARCHAR2 (10) := '';
        l_files      ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
    BEGIN
        l_pr_files := ikis_sysweb.tbl_some_files ();

        FOR pp IN (SELECT pr.pr_id, pr.com_org
                     FROM payroll  pr
                          JOIN
                          (    SELECT REGEXP_SUBSTR (text,
                                                     '[^(\,)]+',
                                                     1,
                                                     LEVEL)    AS z_pr_id
                                 FROM (SELECT p_pr_list AS text FROM DUAL)
                           CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                             '[^(\,)]+',
                                                             1,
                                                             LEVEL)) > 0) z
                              ON z.z_pr_id = pr.pr_id
                    WHERE pr.pr_pay_tp = 'POST')
        LOOP
            l_files := ikis_sysweb.tbl_some_files ();

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            BuildPaymentB1M (pp.pr_id, p_rpt);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('b1-m.txt', p_rpt);
            END IF;

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            BuildPaymentB4M (pp.pr_id,                   /*p_org_id,p_asopd,*/
                                       p_rpt);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('b4-m.txt', p_rpt);
            END IF;

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            BuildPaymentB5M (pp.pr_id,                 /* p_org_id, p_asopd,*/
                                       p_rpt);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('b5-m.txt', p_rpt);
            END IF;

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            BuildPaymentB6M (pp.pr_id,                  /*p_org_id, p_asopd,*/
                                       p_rpt);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('b6-m.txt', p_rpt);
            END IF;

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            BuildPaymentV02M19_Supr (pp.pr_id,          /*p_org_id, p_asopd,*/
                                               p_rpt);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('v02-m19.txt', p_rpt);
            END IF;

            IF l_files.COUNT > 0
            THEN
                l_pr_files.EXTEND;
                p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        'pr_' || pp.com_org || '_' || pp.pr_id || '.zip',
                        p_rpt);
            ELSE
                p_rpt := NULL;
            END IF;
        END LOOP;

        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
            p_rpt_name :=
                   'rpt_post_'
                || TO_CHAR (SYSDATE, 'yyyymmddhh24miss')
                || '.zip';
        ELSE
            p_rpt := NULL;
            p_rpt_name := '';
            RAISE exNoData;
        END IF;
    EXCEPTION
        WHEN exNoData
        THEN
            raise_application_error (
                -20000,
                'Відсутня інформація для побудови файлу друкованих форм відомостей на пошту');
        WHEN OTHERS
        THEN
            IF SQLCODE = -20001 OR SQLCODE = -20000
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'BuildPostFile: '
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
            END IF;
    END BuildPostFile;


    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    -----  #85253  Виплатні документи на банк
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------


    -- Список 1/2 -  SP ZA OR / ZA VKLAD
    FUNCTION BuildSpis2 (p_pr_id       payroll.pr_id%TYPE,
                         p_prs_tp      pr_sheet.prs_tp%TYPE,
                         p_prs_nb      pr_sheet.prs_nb%TYPE:= NULL,
                         p_prs_num     pr_sheet.prs_num%TYPE:= 0,
                         p_mode        NUMBER:= 0,
                         p_format      INT:= 14,
                         p_show_migr   VARCHAR2:= 'F',
                         p_rows_cnt    INT:= 0)                       --#86557
        RETURN BLOB
    IS
        p_rpt                 BLOB;
        l_pr_num              NUMBER := 1;
        l_nbg_name            VARCHAR2 (250);
        l_com_org             NUMBER;
        l_buff                VARCHAR2 (32760);
        l_opfu_name           v_opfu.ORG_NAME%TYPE;
        l_date_start          VARCHAR2 (50);
        l_date_stop           VARCHAR2 (50);
        l_ved_tp              CHAR (20);
        l_pr_pib_manager      payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_bookkeeper   payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_buch         VARCHAR2 (200);
        l_pr_header           uss_ndi.v_ndi_payment_codes.npc_name%TYPE; ---payroll.pr_header%type;
        l_column_width        NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 106                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 74                    --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 65                    --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 56                    --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 203                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 162                  --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 148                  --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 132                  --2 РЛ - 12 шрифт: 135х57
               END;
        l_column_height       NUMBER
            := CASE
                   WHEN p_rows_cnt > 0
                   THEN
                       p_rows_cnt
                   ELSE
                       CASE p_format                         --Slaviq 20070910
                           WHEN 1 THEN 202           --1 РЛ - 8 шрифт: 106х203
                           WHEN 2 THEN 161           --1 РЛ - 10 шрифт: 74х162
                           WHEN 3 THEN 147           --1 РЛ - 11 шрифт: 65х148
                           WHEN 4 THEN 134           --1 РЛ - 12 шрифт: 56х135
                           WHEN 11 THEN 106          --2 РЛ - 8 шрифт: 203х107
                           WHEN 12 THEN 74           --2 РЛ - 10 шрифт: 162х75
                           WHEN 13 THEN 65           --2 РЛ - 11 шрифт: 148х66
                           WHEN 14 THEN 56           --2 РЛ - 12 шрифт: 135х57
                       END
               END;
        l_header_tab          VARCHAR2 (32760)
            :=    /*    PrintCenter('СПИСОК  N <SP_NUM>   ( <BANK_CODE>)',l_column_width) || chr(13) || chr(10) ||
                      '<PR_HEADER>' || chr(13) || chr(10) ||
                      PrintCenter('на поточні (карткові) рахунки одержувачів',l_column_width)|| chr(13) || chr(10) ||
                      '<BANK_NAME>' || chr(13) || chr(10) ||
                      '<BANK_PARAM>'|| chr(13) || chr(10) ||
                      PrintCenter('за період з <DATE_START> по <DATE_STOP>          Тип відомості <N_VED>',l_column_width-4) || chr(13) || chr(10) ||
                      \*'<OPFU_NAME>'  || chr(13) || chr(10) ||*\
                      '<FIN_NAME>'  || chr(13) || chr(10) ||*/
                  PrintCenter ('СПИСОК  N <SP_NUM>   (<BANK_CODE>)',
                               l_column_width)
               || CHR (13)
               || CHR (10)
               || '            НА ЗАРАХУВАННЯ <PR_HEADER>'
               || CHR (13)
               || CHR (10)
               || '            НА ПОТОЧНI РАХУНКИ В '
               || CHR (13)
               || CHR (10)
               || '            <BANK_NAME>'
               || 'Тип відомості <N_VED>'
               || CHR (13)
               || CHR (10)
               || ----  МФО ???    '<BANK_PARAM>'  || chr(13) || chr(10) ||
                  '            ЗА ПЕРIОД З <DATE_START> ПО <DATE_STOP> РОКУ'
               || CHR (13)
               || CHR (10)
               || '            <OPFU_NAME>'
               || CHR (13)
               || CHR (10)
               || '            <FIN_NAME>'
               || CHR (13)
               || CHR (10)
               ||                                                 ---??? <NBG>
                  '<PAGE_NUM_BANK>'
               || CHR (13)
               || CHR (10)
               || CASE
                      WHEN 1 = 1 -- p_show_migr = 'T' -----------and  nvl(tool.GP('USE_IBAN',sysdate), 'F') = 'T'
                      THEN
                             '------------------------------------------------------------------------------------------------------------------------------------'
                          || CHR (13)
                          || CHR (10)
                          || '|  Дата | NN  |             Номер           |                 Прізвище,              |    Сума,    |  Номер   | РЕЄСТРАЦ |ПОЗН.|ПРИ|'
                          || CHR (13)
                          || CHR (10)
                          || '|виплати| П/П |           поточного         |                   ім''я,                |     грн     |пенсійної | НОМЕР ОБЛ|ПРО  |ЧИ-|'
                          || CHR (13)
                          || CHR (10)
                          || '|       |     |            рахунку          |                по батькові             |             |  (ОСОБ)  | КАРТКИ   |ПЕРЕ-|НА |'
                          || CHR (13)
                          || CHR (10)
                          || '|       |     |                             |                                        |             |  справи  | ПЛАТНИКА |БУВА-|НЕ |'
                          || CHR (13)
                          || CHR (10)
                          || '|       |     |                             |                                        |             |          | ПОДАТКIВ |НЯ   |ЗА-|'
                          || CHR (13)
                          || CHR (10)
                          || '|       |     |                             |                                        |             |          |(ЗА НАЯВН)|ВПО  |РАХ|'
                      WHEN p_show_migr = 'T'
                      THEN
                             '--------------------------------------------------------------------------------------------------------------------------'
                          || CHR (13)
                          || CHR (10)
                          || '|Дата |Поряд|      Номер       |             Прізвище,          |    Сума,    |  Номер   |Ідентифі- |Позначка про|Причина|'
                          || CHR (13)
                          || CHR (10)
                          || '|випла|ковий|    поточного     |               ім''я,            |     грн     |пенсійної |каційний  |перебування |неза-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|ти   |номер|   (карткового)   |            по батькові         |             |  справи  |  номер   | на обліку  |раху-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|     |     |     рахунку      |                                |             |          |          | внутрішньо |вання  |'
                          || CHR (13)
                          || CHR (10)
                          || '|     |     |                  |                                |             |          |          | переміщених|       |'
                          || CHR (13)
                          || CHR (10)
                          || '|     |     |                  |                                |             |          |          | осіб       |       |'
                      WHEN NVL (p_show_migr, 'F') = 'F' -------and  nvl(tool.GP('USE_IBAN',sysdate), 'F') = 'T'
                      THEN
                             '------------------------------------------------------------------------------------------------------------------------'
                          || CHR (13)
                          || CHR (10)
                          || '|Дата |Поряд|             Номер           |             Прізвище,          |    Сума,    |  Номер   |Ідентифі- |Причина|'
                          || CHR (13)
                          || CHR (10)
                          || '|випла|ковий|           поточного         |               ім''я,            |     грн     |пенсійної |каційний  |неза-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|ти   |номер|          (карткового)       |            по батькові         |             |  справи  |  номер   |раху-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|     |     |            рахунку          |                                |             |          |          |вання  |'
                      ELSE
                             '-------------------------------------------------------------------------------------------------------------'
                          || CHR (13)
                          || CHR (10)
                          || '|Дата |Поряд|      Номер       |             Прізвище,          |    Сума,    |  Номер   |Ідентифі- |Причина|'
                          || CHR (13)
                          || CHR (10)
                          || '|випла|ковий|    поточного     |               ім''я,            |     грн     |пенсійної |каційний  |неза-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|ти   |номер|   (карткового)   |            по батькові         |             |  справи  |  номер   |раху-  |'
                          || CHR (13)
                          || CHR (10)
                          || '|     |     |     рахунку      |                                |             |          |          |вання  |'
                  END;  -- oivashchuk 20171127 #27183 додано поле позначка ВПО
        l_header_tab_binf     VARCHAR2 (32760)
            :=    '                                       <BANK_CODE>                                    <PAGE_NUM_BANK>'
               || CHR (13)
               || CHR (10)
               || ' за період з <DATE_START> по <DATE_STOP>  <OPFU_NAME>'
               || CHR (13)
               || CHR (10);
        l_header_tab_num      VARCHAR2 (32760)
            := CASE
                   WHEN 1 = 1                            /*p_show_migr = 'T'*/
                   THEN
                          '-------------------------------------------------------------------------------------------------------------------------------------'
                       || CHR (13)
                       || CHR (10)
                       || '|   1   |  2  |               3             |                 4                      |      5      |   6      |   7      |  8  | 9 |'
                       || CHR (13)
                       || CHR (10)
                       || '-------------------------------------------------------------------------------------------------------------------------------------'
                   WHEN p_show_migr = 'T'
                   THEN
                          '--------------------------------------------------------------------------------------------------------------------------'
                       || CHR (13)
                       || CHR (10)
                       || '|  1  |  2  |       3          |             4                  |      5      |   6      |   7      |      8     |   9   |'
                       || CHR (13)
                       || CHR (10)
                       || '--------------------------------------------------------------------------------------------------------------------------'
                   WHEN NVL (p_show_migr, 'F') = 'F'
                   THEN
                          '------------------------------------------------------------------------------------------------------------------------'
                       || CHR (13)
                       || CHR (10)
                       || '|  1  |  2  |              3              |             4                  |      5      |   6      |   7      |   8   |'
                       || CHR (13)
                       || CHR (10)
                       || '------------------------------------------------------------------------------------------------------------------------'
                   ELSE
                          '-------------------------------------------------------------------------------------------------------------'
                       || CHR (13)
                       || CHR (10)
                       || '|  1  |  2  |       3          |             4                  |      5      |   6      |   7      |   8   |'
                       || CHR (13)
                       || CHR (10)
                       || '-------------------------------------------------------------------------------------------------------------'
               END;

        --- #85665 l_date_footer varchar2(32760) := ' Разом (<CUR_DATE>) <CNT_DATE> ПС на суму <SUM_DATE> грн' ;
        l_date_footer         VARCHAR2 (32760)
            :=    '-------------------------------------------------------------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || ' Разом (за кожною датою виплати)  <SUM_DATE> грн';
        l_bnk_page_footer     VARCHAR2 (32760)
            := 'Разом (Аркуш:<PAGE_NUM_BANK>) <PAGE_CNT_BNK> ПС на суму <PAGE_SUM_BNK> грн';
        --  l_org_tp_footer varchar2(32760) := ' Разом (<ORG_TP>) <CNT_OTP> ПС на суму <SUM_OTP> грн' ;
        l_bank_footer         VARCHAR2 (32760)
            :=    CHR (13)
               || CHR (10)
               || 'Усього за списком <CNT_BANK> одержувачів.'
               || CHR (13)
               || CHR (10)
               || 'На загальну суму <SUM_BANK> гривень. <SUM_BANK_PROPIS>'
               || CHR (13)
               || CHR (10)
               || '  КЕРIВНИК ОРГАНУ'
               || CHR (13)
               || CHR (10)
               || '  ПЕНСIЙНОГО ФОНДУ'
               || CHR (13)
               || CHR (10)
               || '  АБО ОРГАНУ'
               || CHR (13)
               || CHR (10)
               || '  СОЦIАЛЬНОГО ЗАХИСТУ                       <PR_PIB_MANAGER>'
               || CHR (13)
               || CHR (10)
               || '  НАСЕЛЕННЯ            ----------------   -------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                            (ПIДПИС)                 (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || '  ГОЛОВНИЙ БУХГАЛТЕР                       <PR_PIB_BUCH> '
               || CHR (13)
               || CHR (10)
               || '                       ----------------   -------------------------------------------'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '       М.П.'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  ПЕРЕВIРЕНО              ПОТОЧНИХ РАХУНКIВ НА СУМУ                           ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '            -------------                           -------------------------'
               || CHR (13)
               || CHR (10)
               || '             (КIЛЬКIСТЬ)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  УПОВНОВАЖЕНИЙ ПРАЦIВНИК БАНКУ'
               || CHR (13)
               || CHR (10)
               || '                                 ----------------   ---------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                    (ПIДПИС)               (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  ЗАРАХОВАНО НА ВКЛАДИ                                                    ОДЕРЖУВАЧIВ'
               || CHR (13)
               || CHR (10)
               || '                        ------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                           (КIЛЬКIСТЬ)'
               || CHR (13)
               || CHR (10)
               || '  НА ЗАГАЛЬНУ СУМУ                                                            ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '                   ----------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                     (ЦИФРАМИ ТА СЛОВАМИ)'
               || CHR (13)
               || CHR (10)
               || '  НЕ ЗАРАХОВАНО НА ВКЛАДИ                                                 ОДЕРЖУВАЧIВ'
               || CHR (13)
               || CHR (10)
               || '                           ----------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                            (КIЛЬКIСТЬ)'
               || CHR (13)
               || CHR (10)
               || '  НА ЗАГАЛЬНУ СУМУ                                                            ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '                   ----------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                     (ЦИФРАМИ ТА СЛОВАМИ)'
               || CHR (13)
               || CHR (10)
               || '  УПОВНОВАЖЕНИЙ ПРАЦIВНИК БАНКУ'
               || CHR (13)
               || CHR (10)
               || '                                 ----------------   ---------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                    (ПIДПИС)               (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '       М.П.'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  (ВIДМIТКА БАНКУ) ';
        /*    'Керівник           ___________ _<PR_PIB_MANAGER>_'   || chr(13) || chr(10) ||
            '                    (підпис)      (ініціали та прізвище)            '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Відповідальна особа ___________ _<PR_PIB_BOOKKEEPER>_'   || chr(13) || chr(10) ||
            '                    (підпис)      (ініціали та прізвище)            '   || chr(13) || chr(10) ||
            '    МП                                                              '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            '____________________________________________________________________'  || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Перевірено ___________ поточних (карткових) рахунків на суму _______ гривень.   '   || chr(13) || chr(10) ||
            '           (кількість)                                              '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Керуючий установи Банку     ___________    ______________________   '   || chr(13) || chr(10) ||
            '                             (підпис)      (ініціали та прізвище)   '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Головний бухгалтер ___________    ______________________            '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Зараховано на вклади ________________________________ одержувачів   '   || chr(13) || chr(10) ||
            '                              (кількість)                           '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'на загальну суму _______________________________________ гривень.   '   || chr(13) || chr(10) ||
            '                        (цифрами та словами)                        '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Не зараховано на вклади _____________________________ одержувачів   '   || chr(13) || chr(10) ||
            '                              (кількість)                           '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'на загальну суму _______________________________________ гривень.   '   || chr(13) || chr(10) ||
            '                        (цифрами та словами)                        '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Керуючий установи Банку     ___________    ______________________   '   || chr(13) || chr(10) ||
            '                             (підпис)      (ініціали та прізвище)   '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            'Головний бухгалтер ___________    ______________________            '   || chr(13) || chr(10) ||
            '                                                                    '   || chr(13) || chr(10) ||
            '    МП                                                              ';
        */


        l_nb_id               payroll.pr_id%TYPE;
        l_nb_num              VARCHAR2 (50) := '0'             /*NUMBER := 0*/
                                                  ;                 --  #86403
        l_page_num            NUMBER := 0;
        l_page_num_bank       NUMBER := 0;
        l_row_num             NUMBER := 0;

        l_cur_date            DATE;
        l_date_cnt            INT;
        l_date_sum            payroll.pr_sum%TYPE; --pr_sheet.prs_sum%TYPE;   -- ivashchuk 20160829 #17541
        l_cur_otp             VARCHAR2 (100); ---v_ddn_organ_tp.dic_sname%type;
        l_otp_cnt             INT;
        l_otp_sum             payroll.pr_sum%TYPE; --pr_sheet.prs_sum%TYPE;   -- ivashchuk 20160829 #17541

        l_page_cnt            INT;
        l_page_sum            payroll.pr_sum%TYPE; --pr_sheet.prs_sum%TYPE;   -- ivashchuk 20160829 #17541

        l_bank_cnt            INT;
        l_bank_sum            payroll.pr_sum%TYPE; --pr_sheet.prs_sum%TYPE;   -- ivashchuk 20160829 #17541



        CURSOR c_rep IS
              SELECT nb_id,
                     l_pr_num
                         AS prs_num,
                     prs_id,
                     TRUNC (prs_pay_dt, 'MM')
                         AS prs_pay_dt,
                        nb_num
                     || CASE
                            WHEN t.nb_filia_num IS NOT NULL
                            THEN
                                '/' || t.nb_filia_num
                        END
                         AS nb_num,
                     nb_sname,
                     prs_account,
                     TRIM (
                            DECODE (
                                nb_num,
                                NULL, NULL,
                                   ' Код:'
                                || nb_num
                                || CASE
                                       WHEN t.nb_filia_num IS NOT NULL
                                       THEN
                                           '/' || t.nb_filia_num
                                   END)
                         || DECODE (nb_mfo, NULL, NULL, ' МФО:' || nb_mfo))
                         bnk_param,
                     ls_name,
                     prs_sum,
                     prs_pc_num,
                     pnf_idcode,
                     pnf_is_migr
                FROM tmp_bank_matrix t                              --  #86403
               WHERE     prs_pr = p_pr_id
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum > 0 ---<> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND nb_id = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
            ORDER BY prs_num,
                     nb_id,
                     DECODE (p_mode, 0, prs_account, NULL), -- Если на банк то сортировка по счету
                     DECODE (p_mode, 0, NULL, prs_pc_num), -- по № ОР ---  Если на ПФУ сортировка по органу
                     prs_pc_num;

        /*SELECT nb_id,
          l_pr_num as prs_num, prs_id,
          trunc(prs_pay_dt, 'MM') as prs_pay_dt,
          nb_num, nb_sname,
          prs_account, --otp.dic_sname pnf_org_tp,
          trim(decode(nb_num,null,null,' Код:'||nb_num)||
            decode(nb_mfo,null,null,' МФО:'||nb_mfo)
           -- ||decode(bnk_account,null,null,' р/р:'||bnk_account)
            ) bnk_param,
          trim(prs_ln||' '||prs_fn||' '||prs_mn) ls_name,
          prs_sum,
          case when length(prs_pc_num) = 15 then ltrim(prs_pc_num, '0')  -- 000000000620820
               when length(prs_pc_num) > 10 and instr(prs_pc_num, '-') > 0 then substr(prs_pc_num, instr(prs_pc_num, '-') + 1)  -- 53001-17465488
               else prs_pc_num
          end  as prs_pc_num,
          nvl(prs_inn,' ') pnf_idcode,
          nb_sname bname,
          '' as pnf_is_migr
        FROM v_payroll, pr_sheet s, uss_ndi.v_ndi_bank b---, particulars, v_pensionfile, v_ddn_organ_tp otp, uss_ndi.v_ndi_bank_master bm
        WHERE pr_id = p_pr_id
          AND pr_id = prs_pr
          and prs_nb = nb_id
          and prs_tp in ('PB'\*,'ABP'*\)  -- #86411 для банків - Виплата банком
          and (prs_tp in ('PB') and prs_sum > 0  ---<> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                 or prs_tp not in ('PB'))
          and prs_tp = p_prs_tp
          and prs_st not in ('PP') -- #86411
          and not exists(select 1
                         from pc_block pb, uss_ndi.v_ndi_reason_not_pay
                         where prs_pcb = pcb_id
                           and pb.pcb_rnp = rnp_id
                           and rnp_code = 'BPRO')
          and (p_prs_nb is null
           or p_prs_nb is not null
           and prs_nb = p_prs_nb)
         and (p_prs_num = 0
          or p_prs_num > 0
          and prs_num = p_prs_num)
        ORDER BY   prs_num, prs_nb,
          decode(p_mode,0,prs_account,null), -- Если на банк то сортировка по счету
          decode(p_mode,0,null,s.prs_pc_num), -- по № ОР ---  Если на ПФУ сортировка по органу
          prs_pc_num;*/
        --Последним сортировка по номеру дела

        v_rep                 c_rep%ROWTYPE;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_row_num := 1;
            l_buff :=
                   LPAD ('(<PAGE_NUM>)', l_column_width - 4, '-')
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CASE WHEN l_page_num > 1 THEN CHR (12) END
                || -- io 20230330 Olga, 19:05 Саша, в ведомостях для матричного там где разделительній рядок можно добавить символ перевода на след страницу (CRLF)?
                   REPLACE (l_buff, '<PAGE_NUM>', LPAD (l_page_num, 4, ' '));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE PageScrool
        IS
            i   INT;
        BEGIN
            l_buff := CHR (13) || CHR (10);

            FOR i IN 1 .. l_column_height - l_row_num
            LOOP
                l_buff := l_buff || CHR (13) || CHR (10);
            END LOOP;

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE StrAppend (l_buff VARCHAR2, x_mode NUMBER DEFAULT 0)
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            FOR cc
                IN (SELECT COLUMN_VALUE     CV
                      FROM TABLE (
                               str2tbl (
                                   REPLACE (l_buff,
                                            CHR (13) || CHR (10),
                                            '$'),
                                   '$',
                                   l_column_width))                 --  #89511
                                                   )
            LOOP
                IF l_row_num + 1 > l_column_height
                THEN
                    PageScrool;
                    PageHeader;
                END IF;

                l_buff_cv := cc.CV || CHR (13) || CHR (10);
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff_cv)),
                    UTL_RAW.cast_to_raw (l_buff_cv));
                l_row_num := l_row_num + 1;
            END LOOP;
        END;

        PROCEDURE StrAppend_0 (l_buff VARCHAR2, x_mode NUMBER DEFAULT 0)
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            FOR cc
                IN (SELECT COLUMN_VALUE     CV
                      FROM TABLE (
                               str2tbl (l_buff,
                                        CHR (13) || CHR (10),
                                        l_column_width)))
            LOOP
                IF l_row_num + 1 > l_column_height
                THEN
                    PageScrool;
                    PageHeader;
                END IF;

                l_buff_cv := cc.CV || CHR (13) || CHR (10);
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff_cv)),
                    UTL_RAW.cast_to_raw (l_buff_cv));
                l_row_num := l_row_num + 1;
            END LOOP;
        END;

        PROCEDURE TabHeader (p_pp_pn      pr_sheet.prs_num%TYPE,
                             p_nb_num     uss_ndi.v_ndi_bank.nb_num%TYPE,
                             p_nb_sname   uss_ndi.v_ndi_bank.nb_sname%TYPE,
                             p_bnk_prm    VARCHAR2)
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (l_header_tab, '<SP_NUM>', p_pp_pn),
                                '<BANK_CODE>',                      /*'в '||*/
                                                 /*TRIM(p_bnk_number)||'/'||*/
                                TRIM (p_nb_num)),
                            '<BANK_NAME>',
                            PrintLeft (TRIM (p_nb_sname),
                                       l_column_width - 40)),
                        '<BANK_PARAM>',
                        PrintCenter (p_bnk_prm, l_column_width)),
                    '<PAGE_NUM_BANK>',
                    PrintRight ('Аркуш № ' || l_page_num_bank,
                                l_column_width - 10));
            /*dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            l_row_num := l_row_num + 12;*/
            StrAppend (l_buff);
        END;

        PROCEDURE TabHeaderNum (
            p_nb_num   uss_ndi.v_ndi_bank.nb_num%TYPE:= NULL)
        IS
        BEGIN
            IF p_nb_num IS NULL
            THEN
                l_buff := l_header_tab_num;
            --l_row_num := l_row_num + 3;
            ELSE
                l_buff :=
                    REPLACE (
                        REPLACE (l_header_tab_binf || l_header_tab_num,
                                 '<PAGE_NUM_BANK>',
                                 'Аркуш № ' || l_page_num_bank),
                        '<BANK_CODE>',
                        p_nb_num);
            --l_row_num := l_row_num + 5;
            END IF;

            StrAppend (l_buff);
        --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
        END;

        /*PROCEDURE OtpFooter
        IS
        BEGIN
          l_buff := REPLACE(REPLACE(REPLACE(l_org_tp_footer,
            '<ORG_TP>', l_cur_otp),
            '<CNT_OTP>', l_otp_cnt),
            '<SUM_OTP>', to_char(l_otp_sum, '9999999990.00'));
          --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
          l_otp_cnt := 0;
          l_otp_sum := 0;
          --l_row_num := l_row_num + 1;
          StrAppend(l_buff);
        END;*/
        --l_bnk_page_footer varchar2(10000) := 'Разом (Аркуш:<PAGE_NUM_BANK>) <PAGE_CNT_BNK> ПС на суму <PAGE_SUM_BNK> грн' || chr(13) || chr(10);
        PROCEDURE BnkPageFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_bnk_page_footer,
                                 '<PAGE_NUM_BANK>',
                                 l_page_num_bank),
                        '<PAGE_CNT_BNK>',
                        l_page_cnt),
                    '<PAGE_SUM_BNK>',
                    TO_CHAR (l_page_sum, '9999999990.00'));
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            l_page_cnt := 0;
            l_page_sum := 0;
            --l_row_num := l_row_num + 1;
            StrAppend (l_buff);
        END;

        PROCEDURE DateFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_date_footer,
                                 '<CUR_DATE>',
                                 TO_CHAR (l_cur_date, 'DD.MM.YYYY')),
                        '<CNT_DATE>',
                        l_date_cnt - 1),
                    '<SUM_DATE>',
                    LPAD (TO_CHAR (l_date_sum, '9999999990.00'), 60, ' '));
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            l_date_cnt := 1;
            l_date_sum := 0;
            --l_row_num := l_row_num + 1;
            StrAppend (l_buff);
        END;

        PROCEDURE BankFooter (p_nb_num VARCHAR2 DEFAULT NULL)
        IS
        BEGIN
            IF p_mode = 0
            THEN
                BnkPageFooter;
            END IF;

            -- io 20230321 якщо на аркуші лишилося менше 39 рядків - перекидаємо на наступний
            IF l_row_num + 39 + (CASE WHEN p_mode = 0 THEN 1 ELSE 0 END) >
               l_column_height
            THEN
                --dbms_output.put_line('io 20230321: v_rep.nb_num = '||v_rep.nb_num);
                PageHeader;
                l_page_num_bank := l_page_num_bank + 1;
                TabHeaderNum (p_nb_num);
            END IF;

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_bank_footer, '<CNT_BANK>', l_bank_cnt),
                        '<SUM_BANK>',
                        TO_CHAR (l_bank_sum, '9999999990.00')),
                    '<SUM_BANK_PROPIS>',
                    SUM_TO_TEXT (l_bank_sum));
            --l_row_num := l_row_num + /*14*/ 42;
            StrAppend (l_buff);
            /*dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            IF l_row_num + 14 > l_column_height THEN
              PageScrool;
              PageHeader;
            END IF;*/
            l_bank_cnt := 0;
            l_bank_sum := 0;
            l_page_num_bank := 0;
        END;
    BEGIN
        SELECT org_id,
               -- get_org_sname(org_name) as org_name, --pr_start_dt, pr_stop_dt,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,                  --  #89720 Виправити назву УСЗН
               --    upper(to_char(pr_start_dt,'dd month','nls_date_language = UKRAINIAN')),
               --    upper(to_char(pr_stop_dt,'dd month yyyY','nls_date_language = UKRAINIAN'))
               UPPER (
                      TO_CHAR (pr_start_dt, 'dd')
                   || ' '
                   || get_mnth_pad_name (TO_CHAR (pr_start_dt, 'mm'))),
               UPPER (
                      TO_CHAR (pr_stop_dt, 'dd')
                   || ' '
                   || get_mnth_pad_name (TO_CHAR (pr_stop_dt, 'mm'))
                   || ' '
                   || TO_CHAR (pr_stop_dt, 'yyyy')),
               c.npc_code,                           -- звідки брати КОД ?????
               /*tools.*/
               get_acc_setup_pib (0, 1, l_com_org)       /*pr_pib_bookkeeper*/
                                                  ,
               pr_pib_bookkeeper,                                   /*tools.*/
               get_acc_setup_pib (1, 1, l_com_org),
               c.npc_name,
               (SELECT COUNT (1)
                  FROM v_payroll p2
                 WHERE     p2.pr_month = pr.pr_month
                       AND p2.com_org = pr.com_org
                       AND p2.pr_npc = pr.pr_npc
                       AND p2.pr_pay_tp = pr.pr_pay_tp
                       --and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                       AND p2.pr_create_dt <= pr.pr_create_dt),
               (SELECT MAX (b.nbg_sname)
                  FROM uss_ndi.v_ndi_payment_type    t,
                       uss_ndi.v_ndi_budget_program  b
                 WHERE t.npt_npc = npc_id AND npt_nbg = nbg_id)
          INTO l_com_org,
               l_opfu_name,
               l_date_start,
               l_date_stop,
               l_ved_tp,
               l_pr_pib_manager,
               l_pr_pib_bookkeeper,
               l_pr_pib_buch,
               l_pr_header,
               l_pr_num,
               l_nbg_name
          --FROM v_payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr_npc
               JOIN v_opfu op ON pr.com_org = org_id
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id AND com_org = org_id AND c.npc_id = pr.pr_npc;

        /* select max(f.fnc_ln||' '||f.fnc_fn||' '||f.fnc_mn) into l_pr_pib_bookkeeper
         from uss_ndi.v_ndi_functionary f
         where f.fnc_tp = 'A' -- Головний бухгалтер
           and f.history_status = 'A'
           and f.com_org = l_com_org;

         select max(f.fnc_ln||' '||f.fnc_fn||' '||f.fnc_mn) into l_pr_pib_manager
         from uss_ndi.v_ndi_functionary f
         where f.fnc_tp = 'D' -- Керівник
           and f.history_status = 'A'
           and f.com_org = l_com_org;*/

        l_header_tab := REPLACE (l_header_tab, '<PER_NUM>', '1');
        l_header_tab := REPLACE (l_header_tab, '<DATE_START>', l_date_start);
        l_header_tab := REPLACE (l_header_tab, '<DATE_STOP>', l_date_stop);
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<OPFU_NAME>',
                     Printleft (l_opfu_name, l_column_width - 12));
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<FIN_NAME>',
                     Printleft (l_nbg_name, l_column_width - 12));
        l_header_tab := REPLACE (l_header_tab, '<N_VED>', l_ved_tp);
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<PR_HEADER>',
                     Printleft (l_pr_header, l_column_width - 30));

        l_header_tab_binf := REPLACE (l_header_tab_binf, '<PER_NUM>', '1');
        l_header_tab_binf :=
            REPLACE (l_header_tab_binf, '<DATE_START>', l_date_start);
        l_header_tab_binf :=
            REPLACE (l_header_tab_binf, '<DATE_STOP>', l_date_stop);
        l_header_tab_binf :=
            REPLACE (l_header_tab_binf, '<OPFU_NAME>', l_opfu_name);
        l_bank_footer :=
            REPLACE (l_bank_footer, '<PR_PIB_MANAGER>', l_pr_pib_manager);
        l_bank_footer :=
            REPLACE (l_bank_footer, '<PR_PIB_BUCH>', l_pr_pib_buch);
        l_bank_footer :=
            REPLACE (l_bank_footer,
                     '<PR_PIB_BOOKKEEPER>',
                     l_pr_pib_bookkeeper);

        --  dbms_lob.createtemporary(lob_loc => p_rpt,cache => true);
        --  dbms_lob.open(lob_loc => p_rpt,open_mode => dbms_lob.lob_readwrite);

        l_nb_id := 0;
        l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
        l_date_cnt := 1;
        l_date_sum := 0;
        l_otp_cnt := 1;
        l_otp_sum := 0;
        l_bank_cnt := 0;
        l_bank_sum := 0;
        l_page_cnt := 0;
        l_page_sum := 0;
        DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => p_rpt, open_mode => DBMS_LOB.lob_readwrite);

        FOR v_rep IN c_rep
        LOOP
            IF l_nb_id <> v_rep.nb_id
            THEN
                IF l_nb_id <> 0
                THEN
                    /*        IF p_mode = 1 THEN
                                OtpFooter;
                            END IF;*/
                    -- футер для даты
                    DateFooter;
                    -- футер для банка
                    /*        -- io 20230321 якщо на аркуші лишилося менше 39 рядків - перекидаємо на наступний
                            IF l_row_num + 39 + (case when p_mode = 0 then 1 else 0 end) > l_column_height THEN
                              PageHeader;
                              l_page_num_bank := l_page_num_bank + 1;
                              TabHeaderNum(v_rep.nb_num);
                            END IF;  */
                    BankFooter (l_nb_num);

                    PageScrool;
                END IF;

                l_page_num_bank := 1;
                l_page_cnt := 0;
                l_page_sum := 0;
                -- page header
                PageHeader;
                TabHeader (v_rep.prs_num,
                           v_rep.nb_num,
                           v_rep.nb_sname,
                           v_rep.bnk_param);
                TabHeaderNum;
                l_nb_id := v_rep.nb_id;
                l_nb_num := v_rep.nb_num;
                l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
                -- l_cur_otp := v_rep.pnf_org_tp;
                l_otp_cnt := 0;
                l_otp_sum := 0;
            END IF;

            IF l_cur_date <> v_rep.prs_pay_dt
            THEN
                IF l_cur_date <> TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                THEN
                    DateFooter;
                END IF;

                l_cur_date := v_rep.prs_pay_dt;
            END IF;

            /*    IF l_cur_otp <> v_rep.pnf_org_tp and p_mode = 1 THEN
                  OtpFooter;
                  l_cur_otp := v_rep.pnf_org_tp ;
                END IF;*/
            IF l_row_num + 1 + (CASE WHEN p_mode = 0 THEN 1 ELSE 0 END) >
               l_column_height
            THEN
                IF p_mode = 0
                THEN
                    BnkPageFooter;
                END IF;

                PageScrool;
                PageHeader;
                l_page_num_bank := l_page_num_bank + 1;
                TabHeaderNum (v_rep.nb_num);
            --TabHeader(v_rep.prs_num, v_rep.nb_num, v_rep.nb_num, v_rep.nb_sname);
            END IF;

            l_buff :=
                   '|'
                || PrintLeft (TO_CHAR (v_rep.prs_pay_dt, 'MM/YYYY'), 7)
                || '|'
                || PrintRight (l_date_cnt, 5)
                || '|'
                || PrintRight (v_rep.prs_account, 29)
                || '|'
                || PrintLeft (v_rep.ls_name, 40                         /*32*/
                                               )
                || '|'
                || TO_CHAR (ROUND (v_rep.prs_sum, 2), '999999990.00')
                || '|'
                || PrintLeft (v_rep.prs_pc_num, 10)
                || '|'
                || PrintLeft (v_rep.pnf_idcode, 10)
                || CASE
                       WHEN 1 = 1                         -- p_show_migr = 'T'
                       THEN
                           '|' || PrintRight (v_rep.pnf_is_migr, 5)
                       ELSE
                           ''
                   END
                || '|   |'
                || CHR (13)
                || CHR (10);
            l_row_num := l_row_num + 1;
            l_bank_sum := l_bank_sum + v_rep.prs_sum;
            l_bank_cnt := l_bank_cnt + 1;
            l_date_cnt := l_date_cnt + 1;
            l_date_sum := l_date_sum + v_rep.prs_sum;
            l_page_cnt := l_page_cnt + 1;
            l_page_sum := l_page_sum + v_rep.prs_sum;
            l_otp_cnt := l_otp_cnt + 1;
            l_otp_sum := l_otp_sum + v_rep.prs_sum;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));

            IF l_date_cnt = 315
            THEN
                NULL;
            END IF;
        /*IF l_row_num + 1 >= l_column_height and p_mode = 0 THEN
          BnkPageFooter;
        end if;*/
        END LOOP;

        IF l_bank_cnt > 0
        THEN
            /*    IF p_mode = 1 THEN
                  OtpFooter;
                END IF;*/
            -- футер для даты
            DateFooter;
            /*        -- io 20230321 якщо на аркуші лишилося менше 39 рядків - перекидаємо на наступний
                    IF l_row_num + 39 + (case when p_mode = 0 then 1 else 0 end) > l_column_height THEN
                      PageHeader;
                      l_page_num_bank := l_page_num_bank + 1;
                      TabHeaderNum(v_rep.nb_num);
                    END IF; */
            BankFooter;
            PageScrool;
        END IF;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86257
        add_CT_ASCII_FF (p_rpt); -- io 20230504 OZ: просють для матричних в кінці документу вставити символ переводу сторінки, щоб новий документ друкувався з нової сторінки
        RETURN p_rpt;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості для формування "СПИСОК НА ЗАРАХУВАННЯ"');
        WHEN OTHERS
        THEN
            --raise_application_error(-20000,'Помилка підготовки даних для звіту "Список2": '|| chr(13) || chr(10) ||sqlerrm);
            raise_application_error (
                -20000,
                   REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || ' '
                || DBMS_UTILITY.format_error_backtrace);
    END;

    --  ОПИС СПИСКIВ -- V 0 2 M 2 3
    FUNCTION BuildOpis2 (p_pr_id      payroll.pr_id%TYPE,
                         p_prs_tp     pr_sheet.prs_tp%TYPE,
                         p_prs_nb     pr_sheet.prs_nb%TYPE:= NULL,
                         p_prs_num    pr_sheet.prs_num%TYPE:= 0,
                         p_format     INT:= 14,
                         p_rows_cnt   INT:= 0)                        --#86557
        RETURN BLOB
    IS
        p_rpt                 BLOB;
        l_pr_num              NUMBER := 1;
        l_com_org             NUMBER;
        l_nbg_name            VARCHAR2 (200);
        l_buff                VARCHAR2 (32760);
        l_opfu_name           v_opfu.ORG_NAME%TYPE;
        l_date_start          VARCHAR2 (100);
        l_date_stop           VARCHAR2 (100);
        l_ved_tp              CHAR (20);
        l_pr_pib_manager      payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_bookkeeper   payroll.pr_pib_bookkeeper%TYPE;
        l_pr_header           uss_ndi.v_ndi_payment_codes.npc_name%TYPE; ---payroll.pr_header%type;

        l_column_width        NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 106                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 74                    --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 65                    --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 56                    --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 203                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 162                  --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 148                  --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 132                  --2 РЛ - 12 шрифт: 135х57
               END;
        l_column_height       NUMBER
            := CASE
                   WHEN p_rows_cnt > 0
                   THEN
                       p_rows_cnt
                   ELSE
                       CASE p_format                         --Slaviq 20070910
                           WHEN 1 THEN 202           --1 РЛ - 8 шрифт: 106х203
                           WHEN 2 THEN 161           --1 РЛ - 10 шрифт: 74х162
                           WHEN 3 THEN 147           --1 РЛ - 11 шрифт: 65х148
                           WHEN 4 THEN 134           --1 РЛ - 12 шрифт: 56х135
                           WHEN 11 THEN 106          --2 РЛ - 8 шрифт: 203х107
                           WHEN 12 THEN 74           --2 РЛ - 10 шрифт: 162х75
                           WHEN 13 THEN 65           --2 РЛ - 11 шрифт: 148х66
                           WHEN 14 THEN 56           --2 РЛ - 12 шрифт: 135х57
                       END
               END;

        l_column_width2       NUMBER := 63;
        --- PrintCenter('ОПИС',l_column_width)  || chr(13) || chr(10) ||

        l_page_body           VARCHAR2 (32000)
            :=    ' ----------------------------------------------------------------  КЕРIВНИК (<BANK_PAGE>)'
               || CHR (13)
               || CHR (10)
               || '                                                      V 0 2 M 2 3  ПЕНСIЙНОГО ФОНДУ'
               || CHR (13)
               || CHR (10)
               || '                           ОПИС СПИСКIВ                            АБО ОРГАНУ'
               || CHR (13)
               || CHR (10)
               || '   НА ЗАРАХУВАННЯ <PR_HEADER>  СОЦIАЛЬНОГО ЗАХИСТУ              <PR_PIB_MANAGER>'
               || CHR (13)
               || CHR (10)
               || '   <PR_HEADER2>  НАСЕЛЕННЯ            ----------  ------------------------------'
               || CHR (13)
               || CHR (10)
               || '   НА ПОТОЧНI РАХУНКИ, ПЕРЕДАНИХ                                                         (ПIДПИС)      (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || '   <BANK_NAME>  ГОЛОВНИЙ БУХГАЛТЕР               <PR_PIB_BOOKKEEPER>'
               || CHR (13)
               || CHR (10)
               || '   ЗА ПЕРIОД З <DATE_START> ПО <DATE_STOP> РОКУ                                 ----------  ------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                 ТИП ВIДОМОСТI <VED_TP>      М.П.'
               || CHR (13)
               || CHR (10)
               || '   <OPFU_NAME>'
               || CHR (13)
               || CHR (10)
               || '   ЗА РАХУНОК КОШТIВ: <FIN_NAME> ПЕРЕВIРЕНО СПИСКIВ       НА СУМУ                        ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '                                                      АРКУШ N <BANK_PAGE2>                     ------        ------------------------'
               || CHR (13)
               || CHR (10)
               || '  ----------T--------------T---------T-----------T---------------                  (КIЛЬКIСТЬ)'
               || CHR (13)
               || CHR (10)
               || '     ДАТА   ¦НОМЕР УСТАНОВИ¦  НОМЕР  ¦ КIЛЬКIСТЬ ¦     СУМА,       УПОВНОВАЖЕНИЙ ПРАЦIВНИК БАНКУ'
               || CHR (13)
               || CHR (10)
               || '    ВИПЛАТИ ¦(ФIЛIЇ) БАНКУ ¦ СПИСКУ  ¦ОДЕРЖУВАЧIВ¦    ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '  ----------+--------------+---------+-----------+---------------                       ----------  ------------------------------'
               || CHR (13)
               || CHR (10)
               || '       1    ¦       2      ¦    3    ¦     4     ¦       5                               (ПIДПИС)      (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || '  ----------+--------------+---------+-----------+---------------'
               || CHR (13)
               || CHR (10)
               || '                                                                   ЗАРАХОВАНО НА ВКЛАДИ              ОДЕРЖУВАЧIВ'
               || CHR (13)
               || CHR (10)
               || '  <CUR_MONTH> <BANK_NUM> <LIST_NUM> <CNT_BANK>    <SUM_BANK>                       ------------'
               || CHR (13)
               || CHR (10)
               || '  --------------------------------      ------    ---------------  НА ЗАГАЛЬНУ СУМУ                                        ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '  РАЗОМ (ЗА КОЖНОЮ ДАТОЮ ВИПЛАТИ):    <CNT_BANK>    <SUM_BANK>                   --------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                                   НЕ ЗАРАХОВАНО НА ВКЛАДИ              ОДЕРЖУВАЧIВ'
               || CHR (13)
               || CHR (10)
               || '  ---------------------------------------------------------------                          ------------'
               || CHR (13)
               || CHR (10)
               || '  УСЬОГO    <CNT_BANK>   ОДЕРЖУВАЧIВ                                 НА ЗАГАЛЬНУ СУМУ                                        ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '  НА ЗАГАЛЬНУ СУМУ          <SUM_BANK>                                                --------------------------------------'
               || CHR (13)
               || CHR (10)
               || '  <SUM_BANK_PROPIS>  ПОВЕРНУТО ЗА ПЛАТIЖНИМИ ДОРУЧЕННЯМИ:'
               || CHR (13)
               || CHR (10)
               || '  <SUM_BANK_PROPIS2>'
               || CHR (13)
               || CHR (10)
               || '                                                                   №       ВIД "   "              20   Р.'
               || CHR (13)
               || CHR (10)
               || '                                                                    ------      ---  ------------   --'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                                   ---------------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                                   (НАЗВА ОРГАНУ ПЕНСIЙНОГО ФОНДУ АБО ОРГАНУ СОЦ. ЗАХ. НАСЕЛЕННЯ)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                                   НА ЗАГАЛЬНУ СУМУ                                        ГРИВЕНЬ'
               || CHR (13)
               || CHR (10)
               || '                                                                                   ----------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                                                             (ЦИФРАМИ ТА СЛОВАМИ)'
               || CHR (13)
               || CHR (10)
               || '                                                                   УПОВНОВАЖЕНИЙ ПРАЦIВНИК БАНКУ'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                                                        ----------  ------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                                                         (ПIДПИС)      (ПРIЗВИЩЕ ТА IНIЦIАЛИ)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                                        М.П.'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                                   (ВIДМIТКА БАНКУ)'
               || CHR (13)
               || CHR (10);


        l_page_num            NUMBER := 0;
        l_page_num_bank       NUMBER := 0;
        l_row_num             NUMBER := 0;

        l_bnk_number          VARCHAR2 (150);

        l_cur_date            DATE;
        l_date_cnt            INT;
        l_date_sum            NUMBER (14, 2);
        l_bank_cnt            INT;
        l_bank_sum            NUMBER (14, 2);
        phaze                 INTEGER := 0;


        CURSOR c_rep IS
              SELECT TRUNC (MIN (prs_pay_dt), 'MM')                AS prs_pay_dt,
                        t.nb_num
                     || CASE
                            WHEN t.nb_filia_num IS NOT NULL
                            THEN
                                '/' || t.nb_filia_num
                        END                                        AS nb_num,
                     l_pr_num                                      AS prs_num,
                     MAX (                                 /*b.nb_num||' '||*/
                          NVL (b.nb_sname, b.nb_name))             bname,
                     MAX (
                            TRIM (
                                   DECODE (
                                       t.nb_num,
                                       NULL, NULL,
                                          ' Код:'
                                       || t.nb_num
                                       || CASE
                                              WHEN t.nb_filia_num IS NOT NULL
                                              THEN
                                                  '/' || t.nb_filia_num
                                          END)
                                || DECODE (t.nb_mfo,
                                           NULL, NULL,
                                           ' МФО:' || t.nb_mfo))
                         || DECODE (b.nb_edrpou,
                                    NULL, NULL,
                                    ' ЄДРПОУ:' || b.nb_edrpou))    bnk_param,
                     COUNT (*)                                     AS c,
                     SUM (prs_sum)                                 AS s
                FROM tmp_bank_matrix t, uss_ndi.v_ndi_bank b        --  #86403
               WHERE     prs_pr = p_pr_id
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum                /*<*/
                                                          > 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND prs_st NOT IN ('PP')
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND t.nb_id = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
                     AND t.nb_id = b.nb_id
            GROUP BY    t.nb_num
                     || CASE
                            WHEN t.nb_filia_num IS NOT NULL
                            THEN
                                '/' || t.nb_filia_num
                        END                          /*, prs_pay_dt, prs_num*/
            ORDER BY nb_num                          /*, prs_pay_dt, prs_num*/
                           ;

        /*SELECT trunc(min(prs_pay_dt),'MM') as prs_pay_dt, b.nb_num nb_num,
          l_pr_num as prs_num,
          max(\*b.nb_num||' '||*\nvl(b.nb_sname,b.nb_name)) bname,
          max(trim(decode(nb_num,null,null,' Код:'||nb_num)||
          decode(nb_mfo,null,null,' МФО:'||nb_mfo)\*||
          decode(bnk_account,null,null,' р/р:'||bnk_account)*\)||
          decode(b.nb_edrpou,null,null,' ЄДРПОУ:'||b.nb_edrpou)) bnk_param,
          COUNT(*) AS c, SUM(prs_sum) AS s
        FROM v_payroll, pr_sheet, uss_ndi.v_ndi_bank b
        WHERE pr_id = p_pr_id
          AND pr_id = prs_pr
          and prs_nb = nb_id
          and prs_tp in ('PB'\*,'ABP'*\)  -- #86411 для банків - Виплата банком
          and (prs_tp in ('PB') and prs_sum \*<*\> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
             or prs_tp not in ('PB'))
          and prs_tp = p_prs_tp
          and prs_st not in ('PP') -- #86411
          and not exists(select 1
                         from pc_block pb, uss_ndi.v_ndi_reason_not_pay
                         where prs_pcb = pcb_id
                           and pb.pcb_rnp = rnp_id
                           and rnp_code = 'BPRO')
          and (p_prs_nb is null
           or p_prs_nb is not null
           and prs_nb = p_prs_nb)
         and (p_prs_num = 0
          or p_prs_num > 0
          and prs_num = p_prs_num)
        GROUP BY  b.nb_num\*, prs_pay_dt, prs_num*\
        ORDER BY  nb_num\*, prs_pay_dt, prs_num*\;*/


        PROCEDURE BankPage (p_bname      VARCHAR2,
                            p_month      VARCHAR2,
                            p_nb_num     VARCHAR2,
                            p_list_num   NUMBER,
                            p_bank_cnt   NUMBER,
                            p_bank_sum   NUMBER)
        IS
            l_bname       VARCHAR2 (1250);
            l_pos         NUMBER;
            l_sum_text    VARCHAR2 (250) := '';
            l_sum_text1   VARCHAR2 (250) := '';
            l_sum_text2   VARCHAR2 (250) := '';
        BEGIN
            ---l_bname := str4size_delim('в '||p_bname,l_column_width, chr(13) || chr(10), l_column_width -1 );
            l_buff :=
                   CASE WHEN l_page_num_bank > 1 THEN CHR (12) END
                ||                                              -- io 20230330
                   REPLACE (
                       REPLACE (
                           REPLACE (l_page_body,
                                    '<BANK_NAME>',              /*PrintRight*/
                                    PrintLeft (p_bname, 62)),
                           '<BANK_PAGE>',
                           LPAD (l_page_num_bank, 4, '0')),
                       '<BANK_PAGE2>',
                       Printright (l_page_num_bank, 3));

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_buff,
                                 '<CUR_MONTH>',
                                 Printright (p_month, 10)),
                        '<BANK_NUM>',
                        Printright (p_nb_num, 14) /*PrintCenter(p_nb_num, l_column_width)*/
                                                 ),
                    '<LIST_NUM>',
                    Printright (p_list_num, 9));

            l_sum_text := SUM_TO_TEXT (p_bank_sum);

            IF LENGTH (l_sum_text) > l_column_width2
            THEN
                l_sum_text :=
                    REPLACE (REPLACE (l_sum_text, ' коп', '#коп'),
                             ' грн',
                             '#грн');
                l_pos :=
                    INSTR (l_sum_text,
                           ' ',
                           -1,
                           1);
                DBMS_OUTPUT.put_line (l_pos);

                IF l_pos > l_column_width2
                THEN
                    l_pos :=
                        INSTR (SUBSTR (l_sum_text, 1, l_column_width2) /*||' '*/
                                                                      ,
                               ' ',
                               -1,
                               1);
                    DBMS_OUTPUT.put_line (
                           '<'
                        || SUBSTR (l_sum_text, 1, l_column_width2)
                        || '> ==> '
                        || l_pos);
                END IF;

                l_sum_text1 := TRIM (SUBSTR (l_sum_text, 1, l_pos));
                l_sum_text2 := TRIM (SUBSTR (l_sum_text, l_pos));
            ELSE
                l_sum_text1 := l_sum_text;
                l_sum_text2 := '';
            END IF;

            l_sum_text1 :=
                REPLACE (REPLACE (l_sum_text1, '#коп', ' коп'),
                         '#грн',
                         ' грн');
            l_sum_text2 :=
                REPLACE (REPLACE (l_sum_text2, '#коп', ' коп'),
                         '#грн',
                         ' грн');

            /*    if length(l_sum_text) > l_column_width2 then
                  l_pos := instr(replace(l_sum_text, ' коп', '#коп'), ' ', -1, 1);
                  if l_pos > l_column_width2 then
                    l_pos := instr(substr(l_sum_text, 1,l_column_width2)||' ', ' ', -1, 1);
                  end if;
                  l_sum_text1 := trim(substr(l_sum_text, 1, l_pos));
                  l_sum_text2 := trim(substr(l_sum_text, l_pos));
                else
                  l_sum_text1 := l_sum_text;
                  l_sum_text2 := '';
                end if;*/

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (l_buff,
                                     '<CNT_BANK>',
                                     Printright (p_bank_cnt, 8)),
                            '<SUM_BANK>',
                            Printright (
                                TO_CHAR (p_bank_sum, '9999999990.00'),
                                15)),
                        '<SUM_BANK_PROPIS>',
                        Printleft (l_sum_text1, l_column_width2)),
                    '<SUM_BANK_PROPIS2>',
                    Printleft (l_sum_text2, l_column_width2));

            -- StrAppend(l_buff);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        ---l_row_num := l_row_num + 17;
        END;
    BEGIN
        --  IKIS_SYSWEB_JOBS.SaveMessage('Розпочато побудову звіту список на виплату банкам');

        SELECT --get_org_sname(org_name) as org_name,  ---pr_start_dt,  pr_stop_dt,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,                  --  #89720 Виправити назву УСЗН
               UPPER (
                      TO_CHAR (pr_start_dt, 'dd')
                   || ' '
                   || get_mnth_pad_name (TO_CHAR (pr_start_dt, 'mm'))),
               UPPER (
                      TO_CHAR (pr_stop_dt, 'dd')
                   || ' '
                   || get_mnth_pad_name (TO_CHAR (pr_stop_dt, 'mm'))
                   || ' '
                   || TO_CHAR (pr_stop_dt, 'yyyy')),
               c.npc_code,                                          /*tools.*/
               get_acc_setup_pib (0, 1, l_com_org)       /*pr_pib_bookkeeper*/
                                                  ,                 /*tools.*/
               get_acc_setup_pib (1, 1, l_com_org)       /*pr_pib_bookkeeper*/
                                                  ,
               c.npc_name,
               (SELECT COUNT (1)
                  FROM v_payroll p2
                 WHERE     p2.pr_month = pr.pr_month
                       AND p2.com_org = pr.com_org
                       AND p2.pr_npc = pr.pr_npc
                       AND p2.pr_pay_tp = pr.pr_pay_tp
                       --and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                       AND p2.pr_create_dt <= pr.pr_create_dt),
               (SELECT MAX (b.nbg_sname)
                  FROM uss_ndi.v_ndi_payment_type    t,
                       uss_ndi.v_ndi_budget_program  b
                 WHERE t.npt_npc = npc_id AND npt_nbg = nbg_id)
          INTO l_opfu_name,
               l_date_start,
               l_date_stop,
               l_ved_tp,
               l_pr_pib_manager,
               l_pr_pib_bookkeeper,
               l_pr_header,
               l_pr_num,
               l_nbg_name
          --FROM v_payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr_npc
               JOIN v_opfu op ON pr.com_org = org_id
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id AND com_org = org_id AND c.npc_id = pr.pr_npc;

        phaze := 1;
        l_page_body :=
            REPLACE (l_page_body,
                     '<DATE_START>',
                     Printleft (l_date_start, 12));
        l_page_body :=
            REPLACE (l_page_body, '<DATE_STOP>', Printleft (l_date_stop, 18));
        l_page_body :=
            REPLACE (l_page_body,
                     '<OPFU_NAME>',
                     Printleft (l_opfu_name, l_column_width2));
        l_page_body :=
            REPLACE (l_page_body, '<FIN_NAME>', Printleft (l_nbg_name, 44));
        l_page_body := REPLACE (l_page_body, '<VED_TP>', l_ved_tp);
        l_page_body := REPLACE (l_page_body, '<PER_NUM>', 1);
        -- #86057 l_page_body := REPLACE(l_page_body, '<PR_HEADER>',PrintCenter(l_pr_header, 47));
        l_page_body :=
            REPLACE (
                l_page_body,
                '<PR_HEADER>',
                PrintCenter (
                    TRIM (
                        SUBSTR (
                            l_pr_header,
                            1,
                            INSTR (SUBSTR (l_pr_header || ' ', 1, 47),
                                   ' ',
                                   -1))),
                    47));
        l_page_body :=
            REPLACE (
                l_page_body,
                '<PR_HEADER2>',
                PrintLeft (
                    TRIM (
                        SUBSTR (
                            l_pr_header,
                            INSTR (SUBSTR (l_pr_header || ' ', 1, 47),
                                   ' ',
                                   -1),
                            62)),
                    62));


        phaze := 2;

        l_page_body :=
            REPLACE (l_page_body, '<PR_PIB_MANAGER>', l_pr_pib_manager);
        l_page_body :=
            REPLACE (l_page_body, '<PR_PIB_BOOKKEEPER>', l_pr_pib_bookkeeper);
        phaze := 3;

        DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => p_rpt, open_mode => DBMS_LOB.lob_readwrite);

        l_bnk_number := '0';
        l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
        l_date_cnt := 0;
        l_date_sum := 0;
        l_bank_cnt := 0;
        l_bank_sum := 0;

        FOR v_rep IN c_rep
        LOOP
            l_page_num_bank := l_page_num_bank + 1;
            -- page header
            phaze := 4;
            DBMS_OUTPUT.put_line (v_rep.nb_num || ' - ' || l_page_num_bank);
            BankPage (p_bname      => v_rep.bname,
                      p_month      => TO_CHAR (v_rep.prs_pay_dt, 'mm/yyyy'),
                      p_nb_num     => v_rep.nb_num,
                      p_list_num   => v_rep.prs_num,
                      p_bank_cnt   => v_rep.c,
                      p_bank_sum   => v_rep.s);

            phaze := 5;
        ---dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
        END LOOP;

        phaze := 6;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86257
        add_CT_ASCII_FF (p_rpt); -- io 20230504 OZ: просють для матричних в кінці документу вставити символ переводу сторінки, щоб новий документ друкувався з нової сторінки
        RETURN p_rpt;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості для формування "ОПИС СПИСКIВ  V 0 2 M 2 3"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Опис2" (фаза -  '
                || phaze
                || '): '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END;

    FUNCTION BuildOpis2_0 (p_pr_id     payroll.pr_id%TYPE,
                           p_prs_tp    pr_sheet.prs_tp%TYPE,
                           p_prs_nb    pr_sheet.prs_nb%TYPE:= NULL,
                           p_prs_num   pr_sheet.prs_num%TYPE:= 0,
                           p_format    INT:= 14)
        RETURN BLOB
    IS
        p_rpt                 BLOB;
        l_pr_num              NUMBER := 1;
        l_com_org             NUMBER;
        l_buff                VARCHAR2 (32760);
        l_opfu_name           v_opfu.ORG_NAME%TYPE;
        l_date_start          VARCHAR2 (10);
        l_date_stop           VARCHAR2 (10);
        l_ved_tp              CHAR (20);
        l_pr_pib_manager      payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_bookkeeper   payroll.pr_pib_bookkeeper%TYPE;
        l_pr_header           uss_ndi.v_ndi_payment_codes.npc_name%TYPE; ---payroll.pr_header%type;

        l_column_width        NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 106                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 74                    --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 65                    --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 56                    --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 203                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 162                  --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 148                  --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 132                  --2 РЛ - 12 шрифт: 135х57
               END;
        l_column_height       NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 202                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 161                   --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 147                   --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 134                   --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 106                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 74                   --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 65                   --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 56                   --2 РЛ - 12 шрифт: 135х57
               END;

        l_header_tab          VARCHAR2 (32760)
            :=    PrintCenter ('ОПИС', l_column_width)
               || CHR (13)
               || CHR (10)
               || '<PR_HEADER>'
               || CHR (13)
               || CHR (10)
               || PrintCenter (
                      'на поточнi (карткові)рахунки одержувачів, переданих',
                      l_column_width)
               || CHR (13)
               || CHR (10)
               || '<BANK_NAME>'
               || CHR (13)
               || CHR (10)
               || '<BANK_PARAM>'
               || CHR (13)
               || CHR (10)
               || PrintCenter ('за період з <DATE_START> по <DATE_STOP>',
                               l_column_width)
               || CHR (13)
               || CHR (10)
               || PrintRight ('Тип відомості <VED_TP>', l_column_width - 10)
               || CHR (13)
               || CHR (10)
               || /*'<OPFU_NAME>'  || chr(13) || chr(10) ||*/
                  '     За рахунок коштів <FIN_NAME>                                 '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '<BANK_PAGE>'
               || CHR (13)
               || CHR (10)
               || '-------------------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '|Дата виплати|Номер підзвітної|  Номер   | Кількість |   Сума,    |'
               || CHR (13)
               || CHR (10)
               || '|            | установи банку |  списку  |одержувачів|  грн.      |'
               || CHR (13)
               || CHR (10)
               || '-------------------------------------------------------------------';

        l_date_footer         VARCHAR2 (10000)
            :=    '|Разом за <CUR_DATE>                       <CNT_DATE>|<SUM_DATE>|'
               || CHR (10);
        l_bank_footer         VARCHAR2 (10000)
            :=    'Усього <CNT_BANK> одержувачів.                                     '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' На загальну суму <SUM_BANK> гривень. <SUM_BANK_PROPIS>'
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Керівник           ___________    _<PR_PIB_MANAGER>_'
               || CHR (13)
               || CHR (10)
               || '                     (підпис)      (ініціали та прізвище)         '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Відповідальна особа ___________    _<PR_PIB_BOOKKEEPER>_'
               || CHR (13)
               || CHR (10)
               || '                      (підпис)      (ініціали та прізвище)         '
               || CHR (13)
               || CHR (10)
               || '     МП                                                           '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Перевірено списків ______________ на суму ______________ гривень.'
               || CHR (13)
               || CHR (10)
               || '                      (кількість)                                 '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Керуючий установи банка ___________    ______________________    '
               || CHR (13)
               || CHR (10)
               || '                          (підпис)      (ініціали та прізвище)    '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Головний бухгалтер ___________    ______________________         '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '     МП                                                           '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Зараховано на  вклади  __________________ одержувачів на загальну'
               || CHR (13)
               || CHR (10)
               || '                           (кількість)                            '
               || CHR (13)
               || CHR (10)
               || 'суму _____ гривень.                                               '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Не зараховано  на  вклади _______________ одержувачів на загальну'
               || CHR (13)
               || CHR (10)
               || '                             (кількість)                          '
               || CHR (13)
               || CHR (10)
               || 'суму ___ гривень.                                                 '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Повернуто за платіжними дорученнями:                             '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' N ______ від ____ ________________ 20__р.                        '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' N ______ від ____ ________________ 20__р.                        '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '__<OPFU_NAME>__'
               || CHR (13)
               || CHR (10)
               || '                  (назва органу Пенсiйного фонду)                 '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' на загальну суму _______________________________________ гривень.'
               || CHR (13)
               || CHR (10)
               || '                            (цифрами та словами)                  '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Керуючий установи Банку ___________    ______________________    '
               || CHR (13)
               || CHR (10)
               || '                          (підпис)      (ініціали та прізвище)    '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || ' Головний бухгалтер ___________    ______________________         '
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '     МП                                                           '
               || CHR (10);


        l_page_num            NUMBER := 0;
        l_page_num_bank       NUMBER := 0;
        l_row_num             NUMBER := 0;

        l_bnk_number          VARCHAR2 (150);

        l_cur_date            DATE;
        l_date_cnt            INT;
        l_date_sum            NUMBER (14, 2);
        l_bank_cnt            INT;
        l_bank_sum            NUMBER (14, 2);
        phaze                 INTEGER := 0;


        CURSOR c_rep IS
              SELECT TRUNC (MIN (prs_pay_dt), 'MM')
                         AS prs_pay_dt,
                     b.nb_num
                         nb_num,
                     l_pr_num
                         AS prs_num,
                     MAX (b.nb_num || ' ' || NVL (b.nb_sname, b.nb_name))
                         bname,
                     MAX (
                            TRIM (
                                   DECODE (nb_num,
                                           NULL, NULL,
                                           ' Код:' || nb_num)
                                || DECODE (nb_mfo,
                                           NULL, NULL,
                                           ' МФО:' || nb_mfo)    /*||
                         decode(bnk_account,null,null,' р/р:'||bnk_account)*/
                                                             )
                         || DECODE (b.nb_edrpou,
                                    NULL, NULL,
                                    ' ЄДРПОУ:' || b.nb_edrpou))
                         bnk_param,
                     COUNT (*)
                         AS c,
                     SUM (prs_sum)
                         AS s
                FROM v_payroll, pr_sheet, uss_ndi.v_ndi_bank b
               WHERE     pr_id = p_pr_id
                     AND pr_id = prs_pr
                     AND prs_nb = nb_id
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum                /*<*/
                                                          > 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND prs_st NOT IN ('PP')                        -- #86411
                     AND NOT EXISTS
                             (SELECT 1
                                FROM pc_block pb, uss_ndi.v_ndi_reason_not_pay
                               WHERE     prs_pcb = pcb_id
                                     AND pb.pcb_rnp = rnp_id
                                     AND rnp_code = 'BPRO')
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND prs_nb = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
            GROUP BY b.nb_num                        /*, prs_pay_dt, prs_num*/
            ORDER BY nb_num                          /*, prs_pay_dt, prs_num*/
                           ;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_row_num := 1;
            l_buff :=
                LPAD ('(<PAGE_NUM>)', l_column_width - 4, '-') || CHR (10);
            l_buff := REPLACE (l_buff, '<PAGE_NUM>', l_page_num);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE PageScrool
        IS
            i   INT;
        BEGIN
            l_buff := CHR (10);

            FOR i IN 1 .. l_column_height - l_row_num
            LOOP
                l_buff := l_buff || CHR (10);
            END LOOP;

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE StrAppend (l_buff VARCHAR2)
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            FOR cc
                IN (SELECT COLUMN_VALUE     CV
                      FROM TABLE (str2tbl (l_buff, CHR (10), l_column_width)))
            LOOP
                IF l_row_num + 1 > l_column_height
                THEN
                    PageScrool;
                    PageHeader;
                END IF;

                l_buff_cv := cc.CV || CHR (10);
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff_cv)),
                    UTL_RAW.cast_to_raw (l_buff_cv));
                l_row_num := l_row_num + 1;
            END LOOP;
        END;

        PROCEDURE TabHeader (p_bname VARCHAR2, p_bnk_param VARCHAR2)
        IS
            l_bname   VARCHAR2 (1250);
        BEGIN
            l_bname :=
                str4size_delim ('в ' || p_bname,
                                l_column_width,
                                CHR (10),
                                l_column_width - 1);
            l_buff :=
                REPLACE (
                    REPLACE (REPLACE (l_header_tab, '<BANK_NAME>', l_bname),
                             '<BANK_PARAM>',
                             PrintCenter (p_bnk_param, l_column_width)),
                    '<BANK_PAGE>',
                    PrintRight ('Аркуш № ' || l_page_num_bank,
                                l_column_width - 10));
            StrAppend (l_buff);
        /*dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
        l_row_num := l_row_num + 17;*/
        END;

        PROCEDURE DateFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_date_footer,
                                 '<CUR_DATE>',
                                 TO_CHAR (l_cur_date, 'DD.MM.YYYY')),
                        '<CNT_DATE>',
                        PrintRight (l_date_cnt, 9)),
                    '<SUM_DATE>',
                    TO_CHAR (ROUND (l_date_sum, 2), '9999999990.00'));
            StrAppend (l_buff);
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            l_date_cnt := 0;
            l_date_sum := 0;
        END;

        PROCEDURE BankFooter
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_bank_footer, '<CNT_BANK>', l_bank_cnt),
                        '<SUM_BANK>',
                        TO_CHAR (l_bank_sum, '9999999990.00')),
                    '<SUM_BANK_PROPIS>',
                    SUM_TO_TEXT (l_bank_sum));
            StrAppend (l_buff);
            /*l_row_num := l_row_num + 54;
            dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            IF l_row_num > l_column_height THEN
              PageScrool;
              PageHeader;
            END IF;*/
            l_bank_cnt := 0;
            l_bank_sum := 0;
            l_page_num_bank := 0;
            l_date_cnt := 0;
            l_date_sum := 0;
        END;
    BEGIN
        --  IKIS_SYSWEB_JOBS.SaveMessage('Розпочато побудову звіту список на виплату банкам');

        SELECT org_name,
               pr_start_dt,
               pr_stop_dt,
               c.npc_code,                           -- звідки брати КОД ?????
               pr_pib_bookkeeper,
               pr_pib_bookkeeper,
               c.npc_name,
               (SELECT COUNT (1)
                  FROM v_payroll p2
                 WHERE     p2.pr_month = pr.pr_month
                       AND p2.com_org = pr.com_org
                       AND p2.pr_npc = pr.pr_npc
                       AND p2.pr_pay_tp = pr.pr_pay_tp
                       --and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                       AND p2.pr_create_dt <= pr.pr_create_dt)
          INTO l_opfu_name,
               l_date_start,
               l_date_stop,
               l_ved_tp,
               l_pr_pib_manager,
               l_pr_pib_bookkeeper,
               l_pr_header,
               l_pr_num
          FROM v_payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
         WHERE pr_id = p_pr_id AND com_org = org_id AND c.npc_id = pr.pr_npc;

        phaze := 1;
        l_header_tab := REPLACE (l_header_tab, '<DATE_START>', l_date_start);
        l_header_tab := REPLACE (l_header_tab, '<DATE_STOP>', l_date_stop);
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<OPFU_NAME>',
                     PrintCenter (l_opfu_name, l_column_width));
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<FIN_NAME>',
                     ' ' || TransformOrgName (l_opfu_name));
        l_header_tab := REPLACE (l_header_tab, '<VED_TP>', l_ved_tp);
        l_header_tab := REPLACE (l_header_tab, '<PER_NUM>', 1);
        l_header_tab :=
            REPLACE (l_header_tab,
                     '<PR_HEADER>',
                     PrintCenter (l_pr_header, l_column_width));
        phaze := 2;

        l_bank_footer :=
            REPLACE (l_bank_footer,
                     '<OPFU_NAME>',
                     PrintCenter (l_opfu_name, l_column_width));
        l_bank_footer :=
            REPLACE (l_bank_footer, '<PR_PIB_MANAGER>', l_pr_pib_manager);
        l_bank_footer :=
            REPLACE (l_bank_footer,
                     '<PR_PIB_BOOKKEEPER>',
                     l_pr_pib_bookkeeper);
        phaze := 3;

        DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => p_rpt, open_mode => DBMS_LOB.lob_readwrite);

        l_bnk_number := '0';
        l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
        l_date_cnt := 0;
        l_date_sum := 0;
        l_bank_cnt := 0;
        l_bank_sum := 0;

        FOR v_rep IN c_rep
        LOOP
            IF l_bnk_number <> v_rep.nb_num
            THEN
                IF l_bnk_number <> '0'
                THEN
                    -- футер для даты
                    DateFooter;
                    -- футер для банка
                    BankFooter;
                    PageScrool;
                END IF;

                l_page_num_bank := l_page_num_bank + 1;
                -- page header
                phaze := 4;
                PageHeader;
                phaze := 5;
                TabHeader (v_rep.bname, v_rep.bnk_param);
                phaze := 6;
                l_bnk_number := v_rep.nb_num;
                l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
            END IF;

            IF l_cur_date <> v_rep.prs_pay_dt
            THEN
                IF l_cur_date <> TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                THEN
                    DateFooter;
                END IF;

                l_cur_date := v_rep.prs_pay_dt;
            END IF;

            IF l_row_num + 1 > l_column_height
            THEN
                phaze := 7;
                PageScrool;
                phaze := 8;
                PageHeader;
                phaze := 9;
                TabHeader (v_rep.bname, v_rep.bnk_param);
            END IF;

            phaze := 10;
            l_buff :=
                   '|'
                || TO_CHAR (v_rep.prs_pay_dt, 'DD.MM.YYYY')
                || '  |'
                || PrintLeft (v_rep.nb_num, 16)
                || '|'
                || PrintCenter (v_rep.prs_num, 10)
                || '|'
                || PrintRight (v_rep.c, 11)
                || '|'
                || TO_CHAR (ROUND (v_rep.s, 2), '9999999990.00')
                || '|'
                || CHR (10);
            phaze := 11;
            l_row_num := l_row_num + 1;
            l_bank_sum := l_bank_sum + v_rep.s;
            l_bank_cnt := l_bank_cnt + v_rep.c;
            l_date_cnt := l_date_cnt + v_rep.c;
            l_date_sum := l_date_sum + v_rep.s;
            phaze := 12;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END LOOP;

        -- футер для даты
        phaze := 13;
        DateFooter;
        phaze := 14;
        BankFooter;
        phaze := 15;
        PageScrool;
        phaze := 16;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86257
        add_CT_ASCII_FF (p_rpt); -- io 20230504 OZ: просють для матричних в кінці документу вставити символ переводу сторінки, щоб новий документ друкувався з нової сторінки
        RETURN p_rpt;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "Опис2" (фаза -  '
                || phaze
                || '): '
                || CHR (10)
                || SQLERRM);
    END;

    -- СУПРОВIДНА  ВIДОМIСТЬ НА ЗАРАХУВАННЯ   V 0 2 M 2 0
    FUNCTION BuildAccompSheet (
        p_pr_id      payroll.pr_id%TYPE,
        p_prs_tp     pr_sheet.prs_tp%TYPE,
        p_prs_nb     pr_sheet.prs_nb%TYPE:= NULL,
        p_prs_num    pr_sheet.prs_num%TYPE:= 0,
        p_format     INT:= 14,
        p_nb_num     uss_ndi.v_ndi_bank.nb_num%TYPE:= NULL,
        p_nb_mfo     uss_ndi.v_ndi_bank.nb_mfo%TYPE:= NULL,
        p_rows_cnt   INT:= 0)                                         --#86557
        RETURN BLOB
    IS
        p_rpt                 BLOB;
        l_buff                VARCHAR2 (32760);
        l_opfu_name           v_opfu.ORG_NAME%TYPE;
        l_date_start          VARCHAR2 (50);
        l_date_stop           VARCHAR2 (50);
        l_pr_num              NUMBER;
        l_ved_tp              CHAR (20);
        l_pr_pib_manager      payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_bookkeeper   payroll.pr_pib_bookkeeper%TYPE;
        l_pr_header           uss_ndi.v_ndi_payment_codes.npc_name%TYPE; ---payroll.pr_header%type;

        l_column_width        NUMBER
            := LEAST (
                   64,
                   CASE p_format                             --Slaviq 20070910
                       WHEN 1 THEN 106               --1 РЛ - 8 шрифт: 106х203
                       WHEN 2 THEN 74                --1 РЛ - 10 шрифт: 74х162
                       WHEN 3 THEN 65                --1 РЛ - 11 шрифт: 65х148
                       WHEN 4 THEN 56                --1 РЛ - 12 шрифт: 56х135
                       WHEN 11 THEN 203              --2 РЛ - 8 шрифт: 203х107
                       WHEN 12 THEN 162              --2 РЛ - 10 шрифт: 162х75
                       WHEN 13 THEN 148              --2 РЛ - 11 шрифт: 148х66
                       WHEN 14 THEN 132              --2 РЛ - 12 шрифт: 135х57
                   END);
        l_column_height       NUMBER
            := CASE
                   WHEN p_rows_cnt > 0
                   THEN
                       p_rows_cnt
                   ELSE
                       CASE p_format                         --Slaviq 20070910
                           WHEN 1 THEN 202           --1 РЛ - 8 шрифт: 106х203
                           WHEN 2 THEN 161           --1 РЛ - 10 шрифт: 74х162
                           WHEN 3 THEN 147           --1 РЛ - 11 шрифт: 65х148
                           WHEN 4 THEN 134           --1 РЛ - 12 шрифт: 56х135
                           WHEN 11 THEN 106          --2 РЛ - 8 шрифт: 203х107
                           WHEN 12 THEN 74           --2 РЛ - 10 шрифт: 162х75
                           WHEN 13 THEN 65           --2 РЛ - 11 шрифт: 148х66
                           WHEN 14 THEN 56           --2 РЛ - 12 шрифт: 135х57
                       END
               END;

        l_header_t            VARCHAR2 (32760)
            :=    PrintRight ('V 0 2 M 2 0', l_column_width - 5)
               || CHR (13)
               || CHR (10)
               || PrintCenter ('СУПРОВIДНА  ВIДОМIСТЬ НА ЗАРАХУВАННЯ',
                               l_column_width - 5)
               || CHR (13)
               || CHR (10)
               || '<PR_HEADER>'
               || CHR (13)
               || CHR (10)
               || ---    PrintCenter('за датами виплати',l_column_width - 5)  || chr(13) || chr(10) ||
                  '  ЗА <PR_NUM> ПЕРІОД <PR_MONTH> РОКУ          ТИП ВIДОМОСТI <VED_TP>'
               || CHR (13)
               || CHR (10)
               || CHR (13)
               || CHR (10)
               || '<OPFU_NAME>'
               || CHR (13)
               || CHR (10)
               || '      --------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '      |Номер установи |  Номер   | Кількість |     Сума,     |'
               || CHR (13)
               || CHR (10)
               || '      | (філії) банку |  списку  |одержувачів|    гривень    |'
               || CHR (13)
               || CHR (10);
        l_header_tab          VARCHAR2 (32760)
            :=    '      --------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '      |        1      |    2     |     3     |        4      |'
               || CHR (13)
               || CHR (10)
               || '      --------------------------------------------------------';
        l_date_footer         VARCHAR2 (10000)
            := '      --------------------------------------------------------';
        --'|Разом за датою виплати <CUR_DATE>         <CNT_DATE>|<SUM_DATE>|';
        l_bank_footer         VARCHAR2 (10000)
            :=    '      |<BANK_NAME>|'
               || CHR (13)
               || CHR (10)
               || '      |Разом                     |<CNT_BANK>|<SUM_BANK>|'
               || CHR (13)
               || CHR (10)
               || '      --------------------------------------------------------';
        l_prt_footer          VARCHAR2 (10000)
            :=    -- '      -----------------------------------------------------------'  || chr(13) || chr(10) ||
                  '      |ВСЬОГО                    |<PR_CNT>|<PR_SUM>|'
               || CHR (13)
               || CHR (10)
               || '      --------------------------------------------------------'
               || CHR (13)
               || CHR (10)
               || '                                                                  '
               || CHR (13)
               || CHR (10)
               || '       ВИДАВ       '
               || CHR (13)
               || CHR (10)
               || '               -------------------------------------------      '
               || CHR (13)
               || CHR (10)
               || '       ОДЕРЖАВ         '
               || CHR (13)
               || CHR (10)
               || '               -------------------------------------------      ';


        l_page_num            NUMBER := 0;
        l_page_num_bank       NUMBER := 0;
        l_row_num             NUMBER := 0;

        l_bnk_num             VARCHAR2 (150);
        l_bnk_name            VARCHAR2 (150);

        l_cur_date            DATE;
        l_date_cnt            INT;
        l_date_sum            payroll.pr_sum%TYPE;
        l_bank_cnt            INT;
        l_bank_sum            payroll.pr_sum%TYPE;
        l_prt_cnt             INT;
        l_prt_sum             payroll.pr_sum%TYPE;

        CURSOR c_rep IS
              SELECT TRUNC (MIN (prs_pay_dt), 'MM')     AS prs_pay_dt,
                     nb_num /* io 20230509 TN:треба прибрати філію в друку || case when t.nb_filia_num is not null then '/'||t.nb_filia_numend*/
                                                        AS nb_num,
                     l_pr_num                           AS prs_num,
                     t.nb_sname                         AS bname,
                     COUNT (*)                          AS c,
                     SUM (prs_sum)                      AS s
                FROM tmp_bank_matrix t                              --  #86403
               WHERE     prs_pr = p_pr_id
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum                /*<*/
                                                          > 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND prs_st NOT IN ('PP')                        -- #86411
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND nb_id = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
                     AND (   p_nb_num IS NULL    -- oivashchuk 20160225 #14354
                          OR     p_nb_num IS NOT NULL
                             AND LPAD (nb_num, 5, '0') =
                                 LPAD (p_nb_num, 5, '0'))
                     AND (   p_nb_mfo IS NULL    -- oivashchuk 20160225 #14354
                          OR     p_nb_mfo IS NOT NULL
                             AND LPAD (nb_mfo, 9, '0') =
                                 LPAD (p_nb_mfo, 9, '0'))
            GROUP BY t.nb_num /*|| case when t.nb_filia_num is not null then '/'||t.nb_filia_num end*/
                             , nb_sname               /*,prs_pay_dt, prs_num*/
            ORDER BY nb_num                          /*,prs_pay_dt,  prs_num*/
                           ;

        /*SELECT
          trunc(min(prs_pay_dt),'MM') as prs_pay_dt, b.nb_num,
          l_pr_num as prs_num,
          b.nb_name as bname,
          COUNT(*) AS c, SUM(prs_sum) AS s
        FROM payroll, pr_sheet, uss_ndi.v_ndi_bank b
        WHERE pr_id = p_pr_id
          AND pr_id = prs_pr
          and prs_nb = nb_id
          and prs_tp in ('PB'\*,'ABP'*\)  -- #86411 для банків - Виплата банком
          and (prs_tp in ('PB') and prs_sum \*<*\> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
             or prs_tp not in ('PB'))
          and prs_tp = p_prs_tp
          and prs_st not in ('PP') -- #86411
          and not exists(select 1
                         from pc_block pb, uss_ndi.v_ndi_reason_not_pay
                         where prs_pcb = pcb_id
                           and pb.pcb_rnp = rnp_id
                           and rnp_code = 'BPRO')
          and (p_prs_nb is null
           or p_prs_nb is not null
           and prs_nb = p_prs_nb)
         and (p_prs_num = 0
          or p_prs_num > 0
          and prs_num = p_prs_num)
         and (p_nb_num is null    -- oivashchuk 20160225 #14354
          or p_nb_num is not null
          and LPAD(nb_num, 5, '0') = LPAD(p_nb_num, 5, '0'))
         and (p_nb_mfo is null    -- oivashchuk 20160225 #14354
          or p_nb_mfo is not null
          and LPAD(nb_mfo, 9, '0') = LPAD(p_nb_mfo, 9, '0'))
        GROUP BY  b.nb_num, nb_name\*,prs_pay_dt, prs_num*\
        ORDER BY nb_num \*,prs_pay_dt,  prs_num*\;*/

        PROCEDURE PageHeader
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_row_num := 1;
            l_buff :=
                   ' '
                || LPAD ('(<PAGE_NUM>)', l_column_width + 3, '-')
                || CHR (13)
                || CHR (10);
            l_buff :=
                REPLACE (l_buff, '<PAGE_NUM>', LPAD (l_page_num, 4, '0'));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE PageScrool
        IS
            i   INT;
        BEGIN
            --l_buff := chr(13) || chr(10);
            FOR i IN 1 .. l_column_height - l_row_num
            LOOP
                l_buff := l_buff || CHR (13) || CHR (10);
            END LOOP;

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE StrAppend (l_buff VARCHAR2)
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            FOR cc
                IN (SELECT COLUMN_VALUE     CV
                      --from table(str2tbl(l_buff, chr(13) || chr(10),l_column_width))
                      FROM TABLE (
                               str2tbl (
                                   REPLACE (l_buff,
                                            CHR (13) || CHR (10),
                                            '$'),
                                   '$',
                                   l_column_width))                 --  #89511
                                                   )
            LOOP
                IF l_row_num + 1 > l_column_height
                THEN
                    PageScrool;
                    PageHeader;
                END IF;

                l_buff_cv := cc.CV || CHR (13) || CHR (10);
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff_cv)),
                    UTL_RAW.cast_to_raw (l_buff_cv));
                l_row_num := l_row_num + 1;
            END LOOP;
        END;

        PROCEDURE TabHeader (p_mode INT:= 0)
        IS
        BEGIN
            l_buff :=
                   CASE WHEN p_mode = 0 THEN l_header_t ELSE CHR (12) END
                || l_header_tab;                    -- +chr(12) -- io 20230330
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            --l_row_num := l_row_num + case when p_mode = 0 then 9 else 0 end + 3;
            StrAppend (l_buff);
        END;

        PROCEDURE DateFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_date_footer,
                                 '<CUR_DATE>',
                                 TO_CHAR (l_cur_date, 'DD.MM.YYYY')),
                        '<CNT_DATE>',
                        PrintRight (l_date_cnt, 9)),
                    '<SUM_DATE>',
                    TO_CHAR (ROUND (l_date_sum, 2), '9999999990.00'));
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            --l_row_num := l_row_num + 1;
            StrAppend (l_buff);
            l_date_cnt := 0;
            l_date_sum := 0;
        END;

        PROCEDURE BankFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_bank_footer,
                                 '<CNT_BANK>',
                                 PrintRight (l_bank_cnt, 11)),
                        '<SUM_BANK>',
                        TO_CHAR (l_bank_sum, '99999999990.00')),
                    '<BANK_NAME>',
                    PrintLeft (l_bnk_name, 54));
            --l_row_num := l_row_num + 1;
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            StrAppend (l_buff);
            l_bank_cnt := 0;
            l_bank_sum := 0;
        END;

        PROCEDURE PrtFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (l_prt_footer,
                                 '<PR_PAYDT>',
                                 TO_CHAR (l_cur_date, 'DD.MM.YYYY')),
                        '<PR_CNT>',
                        PrintRight (l_prt_cnt, 11)),
                    '<PR_SUM>',
                    TO_CHAR (l_prt_sum, '99999999990.00'));
            --l_row_num := l_row_num + 9;
            --dbms_lob.writeappend(p_rpt,dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),utl_raw.cast_to_raw(l_buff));
            StrAppend (l_buff);
            l_prt_cnt := 0;
            l_prt_sum := 0;
        END;
    BEGIN
        l_column_height := l_column_height + 1;

        --  IKIS_SYSWEB_JOBS.SaveMessage('Розпочато побудову звіту список на виплату банкам');

        SELECT ---get_org_sname(org_name) as org_name, --pr_start_dt, pr_stop_dt,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,                  --  #89720 Виправити назву УСЗН
               --upper(to_char(pr_start_dt, 'dd')||' '||get_mnth_pad_name(to_char(pr_start_dt, 'mm'))),
               UPPER (
                   TO_CHAR (pr_start_dt,
                            'month yyyy',
                            'nls_date_language = UKRAINIAN')),
               UPPER (
                      TO_CHAR (pr_stop_dt, 'dd')
                   || ' '
                   || get_mnth_pad_name (TO_CHAR (pr_stop_dt, 'mm'))
                   || ' '
                   || TO_CHAR (pr_stop_dt, 'yyyy')),
               c.npc_code,
               pr_pib_bookkeeper,
               pr_pib_bookkeeper,
               c.npc_name,
               (SELECT COUNT (1)
                  FROM v_payroll p2
                 WHERE     p2.pr_month = pr.pr_month
                       AND p2.com_org = pr.com_org
                       AND p2.pr_npc = pr.pr_npc
                       AND p2.pr_pay_tp = pr.pr_pay_tp
                       --and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                       AND p2.pr_create_dt <= pr.pr_create_dt)
          INTO l_opfu_name,
               l_date_start,
               l_date_stop,
               l_ved_tp,
               l_pr_pib_manager,
               l_pr_pib_bookkeeper,
               l_pr_header,
               l_pr_num
          --FROM v_payroll pr, v_opfu, uss_ndi.v_ndi_payment_codes c
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr_npc
               JOIN v_opfu op ON pr.com_org = org_id
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id AND com_org = org_id AND c.npc_id = pr.pr_npc;


        /*  l_header_t := REPLACE(l_header_t, '<DATE_START>', l_date_start);
          l_header_t := REPLACE(l_header_t, '<DATE_STOP>', l_date_stop);*/
        l_header_t :=
            REPLACE (l_header_t,
                     '<OPFU_NAME>',
                     PrintCenter (l_opfu_name, l_column_width));
        l_header_t := REPLACE (l_header_t, '<VED_TP>', l_ved_tp);
        l_header_t := REPLACE (l_header_t, '<PR_NUM>', l_pr_num);
        l_header_t := REPLACE (l_header_t, '<PR_MONTH>', l_date_start);
        l_header_t :=
            REPLACE (l_header_t,
                     '<PR_HEADER>',
                     PrintCenter (l_pr_header, l_column_width));

        DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => p_rpt, open_mode => DBMS_LOB.lob_readwrite);

        l_bnk_num := '0';
        l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
        l_date_cnt := 0;
        l_date_sum := 0;
        l_bank_cnt := 0;
        l_bank_sum := 0;
        l_prt_cnt := 0;
        l_prt_sum := 0;

        FOR v_rep IN c_rep
        LOOP
            IF l_cur_date <> v_rep.prs_pay_dt
            THEN
                IF l_cur_date <> TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                THEN
                    DateFooter;
                END IF;

                PageHeader;
                TabHeader;
                l_cur_date := v_rep.prs_pay_dt;
            END IF;

            IF l_bnk_num <> v_rep.bname
            THEN
                IF l_bnk_num <> '0'
                THEN
                    -- футер для банка
                    BankFooter;
                END IF;

                l_page_num_bank := l_page_num_bank + 1;
                l_bnk_num := v_rep.nb_num;
                l_bnk_name := v_rep.bname;
            --l_cur_date := to_date('01.01.1900', 'DD.MM.YYYY');
            END IF;

            IF l_row_num + 1 > l_column_height
            THEN
                PageHeader;
                TabHeader (1);
            END IF;

            l_buff :=
                   '      |'
                ||    /* to_char(v_rep.prs_pay_dt, 'DD.MM.YYYY') || '  |' ||*/
                   PrintLeft (v_rep.nb_num, 15)
                || '|'
                || PrintCenter (v_rep.prs_num, 10)
                || '|'
                || PrintRight (v_rep.c, 11)
                || '|'
                || TO_CHAR (ROUND (v_rep.s, 2), '99999999990.00')
                || '|'
                || CHR (13)
                || CHR (10);
            l_row_num := l_row_num + 1;
            l_bank_sum := l_bank_sum + v_rep.s;
            l_bank_cnt := l_bank_cnt + v_rep.c;
            l_date_cnt := l_date_cnt + v_rep.c;
            l_date_sum := l_date_sum + v_rep.s;
            l_prt_cnt := l_prt_cnt + v_rep.c;
            l_prt_sum := l_prt_sum + v_rep.s;
            --l_buff := l_buff || chr(13) || chr(10)|| l_prt_sum;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END LOOP;

        -- футер для даты
        BankFooter;
        DateFooter;
        PrtFooter;

        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86257

        add_CT_ASCII_FF (p_rpt); -- io 20230504 OZ: просють для матричних в кінці документу вставити символ переводу сторінки, щоб новий документ друкувався з нової сторінки

        RETURN p_rpt;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості для формування "СУПРОВIДНА  ВIДОМIСТЬ V 0 2 M 2 0"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "BuildAccompSheet": '
                || CHR (10)
                || SQLERRM
                || ' '
                || DBMS_UTILITY.format_error_backtrace);
    END;



    -- #86403 підготовка даних з розрахунком коду філії/відділення
    PROCEDURE prepare_bank_data (p_pr_id       payroll.pr_id%TYPE,
                                 p_prs_tp      pr_sheet.prs_tp%TYPE,
                                 p_prs_nb      pr_sheet.prs_nb%TYPE:= NULL,
                                 p_prs_num     pr_sheet.prs_num%TYPE:= 0,
                                 p_mode        NUMBER:= 0,
                                 p_show_migr   VARCHAR2:= 'F')
    IS
        l_cnt   NUMBER;
    BEGIN
        DELETE FROM tmp_bank_matrix;

        INSERT INTO uss_esr.tmp_bank_matrix (prs_id,
                                             prs_num,
                                             prs_pr,
                                             prs_tp,
                                             prs_st,
                                             prs_pay_dt,
                                             npc_code,
                                             nb_id,
                                             nb_sname,
                                             nb_mfo,
                                             nb_num,
                                             nb_filia_num,
                                             bnk_param,
                                             prs_account,
                                             ls_name,
                                             prs_sum,
                                             prs_pc_num,
                                             pnf_idcode,
                                             pnf_is_migr)
              SELECT prs_id,
                     1
                         AS prs_num,
                     prs_pr,
                     prs_tp,
                     prs_st,
                     prs_pay_dt,
                     npc_code,
                     nb_id,
                     nb_sname,
                     nb_mfo,
                     nb_num,
                     NULL,
                     TRIM (
                            DECODE (nb_num, NULL, NULL, ' Код:' || nb_num)
                         || DECODE (nb_mfo, NULL, NULL, ' МФО:' || nb_mfo))
                         bnk_param,
                     prs_account,
                     TRIM (prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                         ls_name,
                     prs_sum,
                     CASE
                         WHEN LENGTH (prs_pc_num) = 15
                         THEN
                             LTRIM (prs_pc_num, '0')        -- 000000000620820
                         WHEN     LENGTH (prs_pc_num) > 10
                              AND INSTR (prs_pc_num, '-') > 0
                         THEN
                             SUBSTR (prs_pc_num, INSTR (prs_pc_num, '-') + 1) -- 53001-17465488
                         ELSE
                             prs_pc_num
                     END
                         AS prs_pc_num,
                     NVL (prs_inn, ' ')
                         pnf_idcode,
                     ''
                         AS pnf_is_migr
                FROM v_payroll,
                     pr_sheet                   s,
                     uss_ndi.v_ndi_bank         b,
                     uss_ndi.v_ndi_payment_codes c
               WHERE     pr_id = p_pr_id
                     AND pr_npc = npc_id
                     AND pr_id = prs_pr
                     AND prs_nb = nb_id
                     AND b.nb_nb IS NULL --  #89511 io 20230710  тільки головні банки!
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum > 0 ---<> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND prs_st NOT IN ('PP')                        -- #86411
                     AND NOT EXISTS
                             (SELECT 1
                                FROM pc_block pb, uss_ndi.v_ndi_reason_not_pay
                               WHERE     prs_pcb = pcb_id
                                     AND pb.pcb_rnp = rnp_id
                                     AND rnp_code = 'BPRO')
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND prs_nb = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
            ORDER BY prs_num,
                     prs_nb,
                     DECODE (p_mode, 0, prs_account, NULL), -- Если на банк то сортировка по счету
                     DECODE (p_mode, 0, NULL, s.prs_pc_num), -- по № ОР ---  Если на ПФУ сортировка по органу
                     prs_pc_num;

        --  #89511 io 20230710  тільки головні банки!  пробігаємо філії і підставляємо ГБ
        INSERT INTO uss_esr.tmp_bank_matrix (prs_id,
                                             prs_num,
                                             prs_pr,
                                             prs_tp,
                                             prs_st,
                                             prs_pay_dt,
                                             npc_code,
                                             nb_id,
                                             nb_sname,
                                             nb_mfo,
                                             nb_num,
                                             nb_filia_num,
                                             bnk_param,
                                             prs_account,
                                             ls_name,
                                             prs_sum,
                                             prs_pc_num,
                                             pnf_idcode,
                                             pnf_is_migr)
              SELECT prs_id,
                     1
                         AS prs_num,
                     prs_pr,
                     prs_tp,
                     prs_st,
                     prs_pay_dt,
                     npc_code,
                     -- IC #95535 В друкованих формах на матричний принтер прибрати пошук та переназначення головного банку
                     --nvl(b0.nb_id, b.nb_id) as nb_id,
                     --nvl(b0.nb_sname, b.nb_sname) as nb_sname,
                     --nvl(b0.nb_mfo, b.nb_mfo) as nb_mfo, -- TN: все по ГБ
                     b.nb_id
                         AS nb_id,
                     b.nb_sname
                         AS nb_sname,
                     b.nb_mfo
                         AS nb_mfo,                           -- TN: все по ГБ
                     --LPAD(nvl(b0.nb_num, b.nb_num), 5, '0') nb_num, null,
                     LPAD (b.nb_num, 5, '0')
                         nb_num,
                     NULL,
                     --trim(decode(nvl(b0.nb_num, b.nb_num),null,null,' Код:'||LPAD(nvl(b0.nb_num, b.nb_num), 5, '0') )
                     --              ||decode(nvl(b0.nb_mfo, b.nb_mfo),null,null,' МФО:'||nvl(b0.nb_mfo, b.nb_mfo))) as bnk_param,
                     TRIM (
                            DECODE (b.nb_num,
                                    NULL, NULL,
                                    ' Код:' || LPAD (b.nb_num, 5, '0'))
                         || DECODE (b.nb_mfo, NULL, NULL, ' МФО:' || b.nb_mfo))
                         AS bnk_param,
                     prs_account,
                     TRIM (prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                         ls_name,
                     prs_sum,
                     CASE
                         WHEN LENGTH (prs_pc_num) = 15
                         THEN
                             LTRIM (prs_pc_num, '0')        -- 000000000620820
                         WHEN     LENGTH (prs_pc_num) > 10
                              AND INSTR (prs_pc_num, '-') > 0
                         THEN
                             SUBSTR (prs_pc_num, INSTR (prs_pc_num, '-') + 1) -- 53001-17465488
                         ELSE
                             prs_pc_num
                     END
                         AS prs_pc_num,
                     NVL (prs_inn, ' ')
                         pnf_idcode,
                     ''
                         AS pnf_is_migr
                FROM v_payroll,
                     pr_sheet                   s,
                     uss_ndi.v_ndi_bank         b,
                     uss_ndi.v_ndi_payment_codes c
               --uss_ndi.v_ndi_bank b0 --  #89511 io 20230710       join ikis_rbm.v_recipient r on r.rec_nb = b.nb_id
               WHERE     pr_id = p_pr_id
                     AND pr_npc = npc_id
                     AND pr_id = prs_pr
                     AND prs_nb = b.nb_id
                     --and b.nb_nb=b0.nb_id
                     AND b.nb_nb IS NOT NULL
                     AND prs_tp IN ('PB'                            /*,'ABP'*/
                                        ) -- #86411 для банків - Виплата банком
                     AND (   prs_tp IN ('PB') AND prs_sum > 0 ---<> 0 --НЕ должна выводитться в ведомость сумма пенсии на выплату =0
                          OR prs_tp NOT IN ('PB'))
                     AND prs_tp = p_prs_tp
                     AND prs_st NOT IN ('PP')                        -- #86411
                     AND NOT EXISTS
                             (SELECT 1
                                FROM pc_block pb, uss_ndi.v_ndi_reason_not_pay
                               WHERE     prs_pcb = pcb_id
                                     AND pb.pcb_rnp = rnp_id
                                     AND rnp_code = 'BPRO')
                     AND (   p_prs_nb IS NULL
                          OR p_prs_nb IS NOT NULL AND prs_nb = p_prs_nb)
                     AND (   p_prs_num = 0
                          OR p_prs_num > 0 AND prs_num = p_prs_num)
            ORDER BY prs_num,
                     b.nb_id                                        /*prs_nb*/
                            ,
                     DECODE (p_mode, 0, prs_account, NULL), -- Если на банк то сортировка по счету
                     DECODE (p_mode, 0, NULL, s.prs_pc_num), -- по № ОР ---  Если на ПФУ сортировка по органу
                     prs_pc_num;


        -- визначаємо ід БП (потрібно для подальшого визначення ід ПД з реєсру ВВ)
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.prsd_nbg =
                   (SELECT MAX (npt_nbg)
                      FROM pr_sheet_detail d, uss_ndi.v_ndi_payment_type x
                     WHERE prsd_prs = prs_id AND prsd_npt = npt_id)
         WHERE prsd_nbg IS NULL;

        -- визначаємо ід ПД
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.pe_po =
                   (SELECT MAX (r.pe_po)
                      FROM payroll_reestr r
                     WHERE     1 = 1
                           AND pe_pr = p_pr_id
                           AND pe_nb = nb_id
                           AND pe_pay_dt = prs_pay_dt--and nvl(pe_nbg, -1) = nvl(t.prsd_nbg, -1)  -- TN: це ненормальна ситуація - по одній допомозі по всім складовим повинна бути одна бюджетна програма
                                                     )
         WHERE     pe_po IS NULL
               AND EXISTS
                       (SELECT 1
                          FROM payroll_reestr r
                         WHERE     1 = 1
                               AND pe_pr = p_pr_id
                               AND pe_nb = nb_id
                               AND pe_pay_dt = prs_pay_dt--and nvl(pe_nbg, -1) = nvl(t.prsd_nbg, -1)
                                                         );

        -- контроль на ПД по всіх списках
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_esr.tmp_bank_matrix t
         WHERE pe_po IS NULL;

        /*    #86973  TN прибери поки що, якщо немає прив'язки до ПД може, в електронному виді і не треба буде
          if l_cnt > 0 then
            raise_application_error(-20000,'Помилка підготовки даних по ВВ ід = '||p_pr_id||': не для всіх списків відомості вдалося визначити ПД з реєстру відомостей');
          end if;
          */
        -- визначаємо ід рахунка адресата
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.po_dppa_recipient =
                   (SELECT MAX (po.po_dppa_recipient)
                      FROM pay_order po
                     WHERE po_id = pe_po)
         WHERE po_dppa_recipient IS NULL;

        -- визначаємо код філії/відділення
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.nb_filia_num =
                   (SELECT MAX (LTRIM (a.dppa_nb_filia_num, '/'))
                      FROM uss_ndi.ndi_pay_person_acc a
                     WHERE a.dppa_id = po_dppa_recipient)
         WHERE nb_filia_num IS NULL;

        -- io 20230504
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.nb_filia_num =
                   (SELECT MAX (LTRIM (a.dppa_nb_filia_num, '/'))
                      FROM uss_ndi.ndi_pay_person_acc a
                     WHERE a.dppa_id = po_dppa_recipient)
         WHERE nb_filia_num IS NULL;

        -- #86973 TN: писати, якщо немає прив'язки до ПД, просто 0 в якості філії
        UPDATE uss_esr.tmp_bank_matrix t
           SET t.nb_filia_num = '00000'
         WHERE nb_filia_num IS NULL;
    -- , pnf_is_migr, prsd_nbg, pe_po, po_dppa_recipient
    END;

    -- Формуємо архів з файлами друкованих форм на банк по ВВ
    -- note p_format визначає параметри друку :
    /*  l_column_width  number :=
        case p_format --Slaviq 20070910
          when 1 then 106--1 РЛ - 8 шрифт: 106х203
          when 2 then 74--1 РЛ - 10 шрифт: 74х162
          when 3 then 65--1 РЛ - 11 шрифт: 65х148
          when 4 then 56--1 РЛ - 12 шрифт: 56х135
          when 11 then 203--2 РЛ - 8 шрифт: 203х107
          when 12 then 162--2 РЛ - 10 шрифт: 162х75
          when 13 then 148--2 РЛ - 11 шрифт: 148х66
          when 14 then 132--2 РЛ - 12 шрифт: 135х57
        end;
      l_column_height number :=
        case p_format --Slaviq 20070910
          when 1 then 202--1 РЛ - 8 шрифт: 106х203
          when 2 then 161--1 РЛ - 10 шрифт: 74х162
          when 3 then 147--1 РЛ - 11 шрифт: 65х148
          when 4 then 134--1 РЛ - 12 шрифт: 56х135
          when 11 then 106--2 РЛ - 8 шрифт: 203х107
          when 12 then 74--2 РЛ - 10 шрифт: 162х75
          when 13 then 65--2 РЛ - 11 шрифт: 148х66
          when 14 then 56--2 РЛ - 12 шрифт: 135х57
         end;*/
    -- Формуємо архів з файлами друкованих форм на банк по ВВ
    PROCEDURE BuildBankFile (p_pr_ids     IN            VARCHAR2, -- перелік ід з журналу,
                             ---  p_rows_cnt   int := 0, --#86557
                             p_rpt        IN OUT NOCOPY BLOB,
                             p_rpt_name      OUT        VARCHAR2)
    IS
        p_format     NUMBER := 14;
        p_asopd      VARCHAR2 (10) := '';
        l_files      ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        p_rows_cnt   INT := 0;
    BEGIN
        l_pr_files := ikis_sysweb.tbl_some_files ();

        FOR pp IN (SELECT pr.pr_id, pr.com_org
                     FROM payroll  pr
                          JOIN
                          (    SELECT REGEXP_SUBSTR (text,
                                                     '[^(\,)]+',
                                                     1,
                                                     LEVEL)    AS z_pr_id
                                 FROM (SELECT                    /*p_pr_list*/
                                              p_pr_ids AS text FROM DUAL)
                           CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                             '[^(\,)]+',
                                                             1,
                                                             LEVEL)) > 0) z
                              ON z.z_pr_id = pr.pr_id
                    WHERE pr.pr_pay_tp = 'BANK'-- and pr.pr_id = p_pr_id
                                               )
        LOOP
            prepare_bank_data (p_pr_id       => pp.pr_id, -- #86403 підготовка даних з розрахунком коду філії/відділення
                               p_prs_tp      => 'PB'            /*prs.prs_tp*/
                                                    ,
                               p_prs_nb      => NULL            /*prs.prs_nb*/
                                                    ,
                               p_prs_num     => 0              /*prs.prs_num*/
                                                 ,
                               p_mode        => 1,
                               p_show_migr   => 'T');

            l_files := ikis_sysweb.tbl_some_files ();

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            /*    -- списки та ін. файли - по банках
                for prs in (select prs_nb, prs_tp, \*prs_num,*\ count(1) cnt
                            from pr_sheet s
                            where prs_pr = pp.pr_id
                              and prs_tp = 'PB'
                            group by prs_nb, prs_tp\*, prs_num*\
                            order by prs_nb, prs_tp\*, prs_num*\)
                loop*/
            -- p_mode = 1 - SP ZA OR / p_mode = 0 - ZA VKLAD
            p_rpt :=
                BuildSpis2 (p_pr_id       => pp.pr_id,
                            p_prs_tp      => 'PB'               /*prs.prs_tp*/
                                                 ,
                            p_prs_nb      => NULL               /*prs.prs_nb*/
                                                 ,
                            p_prs_num     => 0                 /*prs.prs_num*/
                                              ,
                            p_mode        => 1,
                            p_format      => p_format,
                            p_show_migr   => 'T',
                            p_rows_cnt    => p_rows_cnt              -- #86557
                                                       );

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('sp_za_or.txt', p_rpt);
            END IF;

            -- p_mode = 1 - SP ZA OR / p_mode = 0 - ZA VKLAD
            p_rpt :=
                BuildSpis2 (p_pr_id       => pp.pr_id,
                            p_prs_tp      => 'PB',
                            p_prs_nb      => NULL,
                            p_prs_num     => 0,
                            p_mode        => 0,
                            p_format      => p_format,
                            p_show_migr   => 'T',
                            p_rows_cnt    => p_rows_cnt              -- #86557
                                                       );

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('sp_za_vklad.txt', p_rpt);
            END IF;

            --  ОПИС СПИСКIВ -- V 0 2 M 2 3
            p_rpt :=
                BuildOpis2 (p_pr_id      => pp.pr_id,
                            p_prs_tp     => 'PB',
                            p_prs_nb     => NULL,
                            p_prs_num    => 0,
                            p_format     => p_format,
                            p_rows_cnt   => p_rows_cnt               -- #86557
                                                      );

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('opys_V02M23.txt', p_rpt);
            END IF;

            -- СУПРОВIДНА  ВIДОМIСТЬ НА ЗАРАХУВАННЯ   V 0 2 M 2 0
            p_rpt :=
                BuildAccompSheet (p_pr_id      => pp.pr_id,
                                  p_prs_tp     => 'PB',
                                  p_prs_nb     => NULL,
                                  p_prs_num    => 0,
                                  p_format     => p_format,
                                  p_nb_num     => NULL,
                                  p_nb_mfo     => NULL,
                                  p_rows_cnt   => p_rows_cnt         -- #86557
                                                            );

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('supr_V02M20.txt', p_rpt);
            END IF;

            --end loop;

            IF l_files.COUNT > 0
            THEN
                l_pr_files.EXTEND;
                p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        'pr_' || pp.com_org || '_' || pp.pr_id || '.zip',
                        p_rpt);
            ELSE
                p_rpt := NULL;
            END IF;
        END LOOP;

        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
            p_rpt_name :=
                   'rpt_bank_'
                || TO_CHAR (SYSDATE, 'yyyymmddhh24miss')
                || '.zip';
        ELSE
            p_rpt := NULL;
            p_rpt_name := '';
            RAISE exNoData;
        END IF;
    EXCEPTION
        WHEN exNoData
        THEN
            raise_application_error (
                -20000,
                'Відсутня інформація для побудови файлу друкованих форм відомостей на банк');
        WHEN OTHERS
        THEN
            IF SQLCODE = -20001 OR SQLCODE = -20000
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'BuildBankFile: '
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
            END IF;
    END BuildBankFile;

    PROCEDURE BuildBankFile_0 (p_pr_id      IN            NUMBER,
                               --p_format     in number,
                               p_rpt        IN OUT NOCOPY BLOB,
                               p_rpt_name      OUT        VARCHAR2)
    IS
        p_format     NUMBER := 14;
        p_asopd      VARCHAR2 (10) := '';
        l_files      ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
    BEGIN
        l_pr_files := ikis_sysweb.tbl_some_files ();

        FOR pp IN (SELECT pr.pr_id, pr.com_org
                     FROM payroll pr
                    /*  join (select regexp_substr(text ,'[^(\,)]+', 1, level)  as z_pr_id
                            from (select p_pr_list as text from dual)
                                  connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0
                            ) z on z.z_pr_id = pr.pr_id*/
                    WHERE pr.pr_pay_tp = 'BANK' AND pr.pr_id = p_pr_id)
        LOOP
            l_files := ikis_sysweb.tbl_some_files ();

            DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => p_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);

            /*    -- списки та ін. файли - по банках
                for prs in (select prs_nb, prs_tp, \*prs_num,*\ count(1) cnt
                            from pr_sheet s
                            where prs_pr = pp.pr_id
                              and prs_tp = 'PB'
                            group by prs_nb, prs_tp\*, prs_num*\
                            order by prs_nb, prs_tp\*, prs_num*\)
                loop*/
            -- p_mode = 1 - SP ZA OR / p_mode = 0 - ZA VKLAD
            p_rpt :=
                BuildSpis2 (p_pr_id       => pp.pr_id,
                            p_prs_tp      => 'PB'               /*prs.prs_tp*/
                                                 ,
                            p_prs_nb      => NULL               /*prs.prs_nb*/
                                                 ,
                            p_prs_num     => 0                 /*prs.prs_num*/
                                              ,
                            p_mode        => 1,
                            p_format      => p_format,
                            p_show_migr   => 'T');

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('sp_za_or.txt', p_rpt);
            END IF;

            -- p_mode = 1 - SP ZA OR / p_mode = 0 - ZA VKLAD
            p_rpt :=
                BuildSpis2 (p_pr_id       => pp.pr_id,
                            p_prs_tp      => 'PB',
                            p_prs_nb      => NULL,
                            p_prs_num     => 0,
                            p_mode        => 0,
                            p_format      => p_format,
                            p_show_migr   => 'T');

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('sp_za_vklad.txt', p_rpt);
            END IF;

            --  ОПИС СПИСКIВ -- V 0 2 M 2 3
            p_rpt :=
                BuildOpis2 (p_pr_id     => pp.pr_id,
                            p_prs_tp    => 'PB',
                            p_prs_nb    => NULL,
                            p_prs_num   => 0,
                            p_format    => p_format);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('opys_V02M23.txt', p_rpt);
            END IF;

            -- СУПРОВIДНА  ВIДОМIСТЬ НА ЗАРАХУВАННЯ   V 0 2 M 2 0
            p_rpt :=
                BuildAccompSheet (p_pr_id     => pp.pr_id,
                                  p_prs_tp    => 'PB',
                                  p_prs_nb    => NULL,
                                  p_prs_num   => 0,
                                  p_format    => p_format,
                                  p_nb_num    => NULL,
                                  p_nb_mfo    => NULL);

            IF p_rpt IS NOT NULL
            THEN
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info ('supr_V02M20.txt', p_rpt);
            END IF;

            --end loop;

            IF l_files.COUNT > 0
            THEN
                l_pr_files.EXTEND;
                p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        'pr_' || pp.com_org || '_' || pp.pr_id || '.zip',
                        p_rpt);
            ELSE
                p_rpt := NULL;
            END IF;
        END LOOP;

        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
            p_rpt_name :=
                   'rpt_bank_'
                || TO_CHAR (SYSDATE, 'yyyymmddhh24miss')
                || '.zip';
        ELSE
            p_rpt := NULL;
            p_rpt_name := '';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF SQLCODE = -20001 OR SQLCODE = -20000
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'BuildBankFile: '
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
            END IF;
    END;


    ---------------------------------------------------------------------------------------------
    -----  Відрахування #90095 Додати друковані форми на матричний принтер по відрахуванням -----
    ---------------------------------------------------------------------------------------------
    --  1. Список по відрахуванням
    PROCEDURE BuildAccrualList_R2 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        ---p_org_id in payroll.com_org%type,
        p_rpt      IN OUT NOCOPY BLOB)
    IS
        p_asopd                  VARCHAR2 (10) := '';
        l_com_org                payroll.com_org%TYPE;
        l_buff                   VARCHAR2 (32767);
        l_buff2                  VARCHAR2 (32767);
        l_pr_start_dt            payroll.pr_start_dt%TYPE;
        l_org_name               v_opfu.org_name%TYPE;
        l_org_code               v_opfu.org_code%TYPE;
        l_per_year               NUMBER (4);      ---nsi_period.per_year%type;
        l_per_month              NUMBER (2);     ---nsi_period.per_month%type;
        l_date_start             VARCHAR2 (10);
        l_date_stop              VARCHAR2 (10);
        l_per_num                NUMBER (14) := 1; --  Виплатний період ?????  payroll.pr_per_num%type;
        l_ved_tp                 CHAR (20);
        l_prs_num                pr_sheet.prs_num%TYPE DEFAULT 0;
        l_org_id                 v_opfu.ORG_ID%TYPE DEFAULT 0;
        l_prs_index              uss_ndi.v_ndi_post_office.npo_index%TYPE DEFAULT NULL;
        l_rn_rep                 PLS_INTEGER DEFAULT 0;
        l_sum_tab                NUMBER;
        l_sum_text               VARCHAR2 (512);
        n                        NUMBER := 1;
        v_address_1              VARCHAR2 (100);
        v_address_2              VARCHAR2 (100);
        l_str_1                  VARCHAR2 (40);
        l_str_2                  VARCHAR2 (40);
        l_str_3                  VARCHAR2 (40);
        l_org_head               VARCHAR2 (40);
        l_org_buh                VARCHAR2 (40);

        v_count                  NUMBER;
        v_instr                  NUMBER;
        l_a_pr_name              VARCHAR2 (100);
        l_a_per_num              VARCHAR2 (20) := 1; --  Виплатний період ?????
        l_npc_name               VARCHAR2 (100);
        l_npc_code               VARCHAR2 (100);
        --l_page_width number := 134;
        --
        Ct_pnf_pib_LENGTH        INTEGER := 40;
        CT_ADDRESS_LENGTH        INTEGER := 40;
        CT_PASSPORT_LENGTH       INTEGER := 15                          /*10*/
                                              ;       --  різні довідки і т.д.
        CT_OPFU_LENGTH           INTEGER := 75;
        CT_CNTR_LENGTH           INTEGER := 28;
        CT_SUM_TEXT_TAB_LENGTH   INTEGER := 103;
        CT_SUM_RTAB_LENGTH       INTEGER := 26;
        --
        l_header_tab             VARCHAR2 (32767)
            :=    '  Код району <ORG_CODE>   Орган, що здiйснює виплату : <ORG_NAME>'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               ||                          --#accomp_desc_num#  #supl_desc_dt#
                  '                             СПИСОК No   <ACCOMP_DESC_NUM>                                                       Дата видачi <SUPL_DATE> р.'
               || CHR (13)
               || CHR (10)
               || '                     сум, вiдрахованих  на користь'
               || CHR (13)
               || CHR (10)
               || '<DPP_NAME>'
               || CHR (13)
               || CHR (10)
               || '<DPP_INFO>'
               || CHR (13)
               || CHR (10)
               || '    розрахунковий рахунок N <DPP_IBAN> у'
               || CHR (13)
               || CHR (10)
               || '<BANK_NAME>'
               || CHR (13)
               || CHR (10)
               ||                              -- особовий рахунок органiзацiї
                  '               МФО <BANK_MFO>  Код <BANK_CODE>   по  ДЕРЖБЮДЖЕТ (СУБВ.)'
               || CHR (13)
               || CHR (10)
               || '                         за  <SUPL_MONTH> р.'
               || CHR (13)
               || CHR (10)
               || '                                                                                                          Аркуш  <PAGE_NUM> (<PAGE_CNT>)'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦Номер ви- ¦                                        ¦                                        ¦            ¦  Сума    ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ No  ¦конавчого ¦   Назва, номер та дата виконавчого     ¦  Прiзвище, iм'' я, по батьковi особи, з ¦   Номер    ¦перераху- ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ п/п ¦документу ¦    документу та вид перерахування      ¦допомоги якого провадиться перерахування¦ особового  ¦вання на  ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦   по     ¦                                        ¦              Адреса                    ¦  рахунку   ¦користь   ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦ реєстру  ¦                                        ¦                                        ¦            ¦одержувача¦'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦          ¦                                        ¦                                        ¦            ¦ грн.коп. ¦'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1  ¦    2     ¦                  3                     ¦                     4                  ¦      5     ¦     6    ¦'
               || CHR (13)
               || CHR (10)--'  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+' || chr(13) || chr(10)
                          ;

        l_header_page            VARCHAR2 (32767)
            :=    '                                                                                                          Аркуш  <PAGE_NUM> (<PAGE_CNT>)'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1  ¦    2     ¦                  3                     ¦                     4                  ¦      5     ¦     6    ¦'
               || CHR (13)
               || CHR (10);
        l_body_tab               VARCHAR2 (32767)
            :=    '  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦<NN>¦<DN_IN_NUM>¦<DN_OUT_NUM>¦<PIB_ADDRESS1>¦<PC_NUM>¦<PP_SUM>¦'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦          ¦<DN_OUT_NUM2>¦<PIB_ADDRESS2>¦            ¦          ¦'
               || CHR (13)
               || CHR (10);
        l_body_line3             VARCHAR2 (1000)
            :=    '  ¦     ¦          ¦                                        ¦<PIB_ADDRESS3>¦            ¦          ¦'
               || CHR (13)
               || CHR (10);

        l_footer_tab             VARCHAR2 (32767)
            :=    '  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '                                                                                                  Всього:     <SUM_TAB> '
               || CHR (13)
               || CHR (10);
        l_footer_tab_end         VARCHAR2 (32767) := '';
        l_footer_doc             VARCHAR2 (32767)
            :=    ''
               || CHR (13)
               || CHR (10)
               || '                     Керiвник органу, що здiйснює виплату <ORG_HEAD>'
               || CHR (13)
               || CHR (10)
               || '      Печатка'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                     Головний бухгалтер <ORG_BUH>'
               || CHR (13)
               || CHR (10)
               || '                     (старший спецiалiст)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     Перераховано______________________________________________'
               || CHR (13)
               || CHR (10)
               || '              (найменування структурного пiдроздiлу з питань соцiального захисту населення)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     платiжним дорученням No _______ вiд _______________________'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '                                                   ______________'
               || CHR (13)
               || CHR (10)
               || '                                                      (пiдпис)'
               || CHR (13)
               || CHR (10);

        l_PAGE_CNT               NUMBER;
        l_page_num               NUMBER := 0;
        l_row_num                NUMBER := 0;
        l_page_height            NUMBER := 15; -- 15 рядків таблиці. для 1-ї сторінки (з шапкою) - лише 10
        l_rep                    t_b1m_table;


        PROCEDURE PageHeader
        IS
        BEGIN
            l_buff2 :=
                   ' -----------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CHR (12)
                || ' -----------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF                                                   /*l_row_num*/
               l_page_num = 0
            THEN
                l_buff := REPLACE (REPLACE (l_buff, CHR (12), ''), '', '');
            ELSIF l_row_num = 0
            THEN
                l_buff := l_buff;
            ELSE
                l_buff :=
                       l_buff
                    || REPLACE (
                           REPLACE (l_header_page,
                                    '<PAGE_NUM>',
                                    PrintRight (l_page_num + 1, 5)),
                           '<PAGE_CNT>',
                           PrintRight (l_PAGE_CNT, 5));
            END IF;

            l_page_num := l_page_num + 1;
            --l_row_num := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE TabHeader (p_ORG_NAME     IN VARCHAR2,
                             p_ORG_CODE     IN VARCHAR2,
                             p_num          IN VARCHAR2,
                             p_SUPL_DATE    IN VARCHAR2,
                             p_DPP_NAME     IN VARCHAR2,
                             p_DPP_INFO     IN VARCHAR2,
                             p_DPP_IBAN     IN VARCHAR2,
                             p_BANK_NAME    IN VARCHAR2,
                             p_BANK_MFO     IN VARCHAR2,
                             p_BANK_CODE    IN VARCHAR2,
                             p_SUPL_MONTH   IN VARCHAR2,
                             p_PAGE_NUM     IN INTEGER,
                             p_PAGE_CNT     IN INTEGER)
        IS
        BEGIN
            DBMS_OUTPUT.put_line (3333);
            l_buff := l_header_tab;
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_CODE>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_CODE, 1, 5)), 5));
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_NAME>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_NAME, 1, 70)), 70)); --
            l_buff :=
                REPLACE (l_buff,
                         '<ACCOMP_DESC_NUM>',
                         PrintLeft (TRIM (p_num), 5)); -- substr(l_npc_name,1,70)
            l_buff :=
                REPLACE (l_buff, '<SUPL_DATE>', PrintLeft (p_SUPL_DATE, 10));
            l_buff :=
                REPLACE (l_buff, '<DPP_NAME>', PrintCenter (p_DPP_NAME, 80));
            l_buff :=
                REPLACE (l_buff, '<DPP_INFO>', PrintCenter (p_DPP_INFO, 80));
            l_buff :=
                REPLACE (l_buff, '<DPP_IBAN>', PrintLeft (p_DPP_IBAN, 30));
            l_buff :=
                REPLACE (l_buff,
                         '<BANK_NAME>',
                         PrintCenter (p_BANK_NAME, 80));
            l_buff :=
                REPLACE (l_buff, '<BANK_MFO>', PrintLeft (p_BANK_MFO, 10));
            l_buff :=
                REPLACE (l_buff, '<BANK_CODE>', PrintLeft (p_BANK_CODE, 10));
            l_buff :=
                REPLACE (l_buff,
                         '<SUPL_MONTH>',
                         PrintLeft (p_SUPL_MONTH, 16));
            l_buff :=
                REPLACE (l_buff, '<PAGE_NUM>', PrintRight (p_PAGE_NUM, 5));
            l_buff :=
                REPLACE (l_buff, '<PAGE_CNT>', PrintRight (p_PAGE_CNT, 5));

            l_rn_rep := 0;
            l_sum_tab := 0;

            /*    l_buff := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_buff,
                  '<PAGE_NUM>', PrintLeft(to_char(l_page_num),10)),
                  '<ACCOMP_DESC_NUM>', PrintRight(to_char(p_num),5)),
                  '<prs_index>', PrintLeft(lpad(trim(to_char(p_prs_index,'99990')),5,'0'),6)),
                  '<ASOPD>', \*PrintLeft(nvl(to_char(p_asopd),' '),7)*\' '),
                  '<CNTR_NAME>', \*PrintLeft*\PrintRight(substr(p_cntr_name,1,CT_CNTR_LENGTH),CT_CNTR_LENGTH)),
                  '<DLVR_CODE>', PrintRight(coalesce(to_char(p_dlvr_code),' '),3)),
                  '<SUPL_DATE>', PrintRight(to_char(p_pp_date,'dd.mm.yyyy'),10)),
                  '<PP_DAY>', PrintRight(p_pp_day,2));*/
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 1;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'TabHeader: '
                    || ', n='
                    || TO_CHAR (n)
                    || ' '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END;

        --
        PROCEDURE TabBody (p_NUM           IN VARCHAR2,
                           p_PC_NUM        IN VARCHAR2,
                           p_pp_sum        IN NUMBER,
                           p_pib           IN VARCHAR2,
                           p_address       IN VARCHAR2,
                           p_DN_IN_NUM     IN VARCHAR2,
                           p_DN_OUT_NUM    IN NUMBER,
                           p_DN_OUT_NUM2   IN VARCHAR2)
        IS
            v_sum     VARCHAR2 (30)
                          := TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '9999990.00'));
            l_pib1    VARCHAR2 (255);
            l_pib2    VARCHAR2 (255);
            l_buff0   VARCHAR2 (32000);

            --
            PROCEDURE get_pnf_pib
            IS
                p1   INTEGER := INSTR (p_pib, ' ', 1);
                p2   INTEGER := INSTR (p_pib, ' ', -1);
                w    INTEGER := LENGTH (p_pib);
            BEGIN
                IF LENGTH (p_pib) <= Ct_pnf_pib_LENGTH
                THEN
                    l_pib1 := p_pib;
                    l_pib2 := NULL;
                ELSE
                    l_pib1 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, 1, p2 - 1)
                            ELSE
                                SUBSTR (p_pib, 1, p1 - 1)
                        END;
                    l_pib2 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, p2 + 1, w - p2)
                            ELSE
                                SUBSTR (p_pib, p1 + 1, w - p1)
                        END;

                    IF GREATEST (LENGTH (l_pib1), LENGTH (l_pib2)) >
                       Ct_pnf_pib_LENGTH
                    THEN
                        l_pib1 := SUBSTR (p_pib, 1, Ct_pnf_pib_LENGTH);
                        l_pib2 :=
                            SUBSTR (p_pib,
                                    Ct_pnf_pib_LENGTH + 1,
                                    Ct_pnf_pib_LENGTH);
                    END IF;
                END IF;
            --case when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,1,Ct_pnf_pib_LENGTH);
            --when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,Ct_pnf_pib_LENGTH + 1,Ct_pnf_pib_LENGTH);
            END;
        BEGIN
            l_rn_rep := l_rn_rep + 1;
            get_pnf_pib;

            /*    if p_ind_lim_value<p_pp_sum then
                  raise_application_error(-20000, 'Знайдена пенсійна виплата, яка перевищує ліміт.
                                                   Індекс поштового зв`язку '||to_char(p_prs_index)||',
                                                   сума ліміту = '||to_char(p_ind_lim_value)||',
                                                   номер пенсійної справи '||p_pnf_number||',
                                                   сума виплати = '||v_sum);
                end if;*/

            v_count :=
                REGEXP_COUNT (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH), ',');

            IF v_count > 0
            THEN
                v_instr :=
                    INSTR (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                           ',',
                           1,
                           v_count);
            ELSE
                v_instr := 0;
            END IF;

            IF     (LENGTH (p_address) > CT_ADDRESS_LENGTH)
               AND (v_count > 0)
               AND (LENGTH (p_address) - v_instr < 30 + 1)
            THEN
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, V_INSTR), ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    V_INSTR + 1 + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            ELSE
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                                  ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    CT_ADDRESS_LENGTH + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            END IF;

            l_str_1 := TRIM (l_pib1);

            IF l_pib2 IS NOT NULL
            THEN
                l_str_2 := TRIM (l_pib2);
                l_str_3 := TRIM (v_address_1);
                l_buff0 := '';
            ELSE
                l_str_2 := TRIM (v_address_1);
                l_str_3 := TRIM (v_address_2);
                l_buff0 := '';
            ---l_buff := l_buff || l_buff2;
            END IF;

            IF l_str_3 IS NOT NULL
            THEN
                l_buff0 :=
                    REPLACE (
                        l_body_line3,
                        '<PIB_ADDRESS3>',
                        PrintLeft (COALESCE (l_str_3, ' '),
                                   Ct_pnf_pib_LENGTH));
            ELSE
                l_buff0 := '';
            END IF;

            /*    dbms_output.put_line('l_pib2='||l_pib2) ;
                dbms_output.put_line('l_str_1='||l_str_1) ;
                dbms_output.put_line('l_str_2='||l_str_2) ;
                dbms_output.put_line('l_str_3='||l_str_3) ;
                dbms_output.put_line('v_address_1='||v_address_1) ;
                dbms_output.put_line('v_address_2='||v_address_2) ;*/

            l_buff :=
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       l_body_tab,
                                                       '<NN>',
                                                       PrintLeft (p_num, 5)),
                                                   '<DN_IN_NUM>',
                                                   PrintLeft (p_DN_IN_NUM,
                                                              10)),
                                               '<DN_OUT_NUM>',
                                               PrintLeft (p_DN_OUT_NUM, 40)),
                                           '<DN_OUT_NUM2>',
                                           PrintLeft (p_DN_OUT_NUM2, 40)),
                                       '<PIB_ADDRESS1>',
                                       PrintLeft (COALESCE (l_str_1, ' '),
                                                  40)),
                                   '<PIB_ADDRESS2>',
                                   PrintLeft (COALESCE (l_str_2, ' '), 40)),
                               '<PIB_ADDRESS3>',
                               PrintLeft (COALESCE (l_str_3, ' '), 40)),
                           '<PC_NUM>',
                           PrintLeft (p_PC_NUM, 12)),
                       '<PP_SUM>',
                       PrintRight (v_sum, 10))
                || l_buff0;

            DECLARE
                l_index3      INTEGER
                                  := CT_ADDRESS_LENGTH + CT_ADDRESS_LENGTH + 1;
                l_len3        INTEGER := CT_ADDRESS_LENGTH;
                l_max_line3   INTEGER := 3;
                i3            INTEGER := 0;
                l_address3    VARCHAR2 (255)
                                  := SUBSTR (p_address, l_index3, l_len3);
                l_buff3       VARCHAR2 (5000);
                --
                l_index4      INTEGER
                    := Ct_pnf_pib_LENGTH + Ct_pnf_pib_LENGTH + 1;
                l_len4        INTEGER := Ct_pnf_pib_LENGTH;
                l_name4       VARCHAR2 (255)
                                  := SUBSTR (p_pib, l_index4, l_len4);
            BEGIN
                WHILE     (l_address3 IS NOT NULL OR l_name4 IS NOT NULL)
                      AND i3 < l_max_line3
                LOOP
                    l_buff3 :=
                        REPLACE (
                            REPLACE (
                                l_body_line3,
                                '<ADDRESS3>',
                                PrintLeft (COALESCE (l_address3, ' '),
                                           l_len3)),
                            '<pib3>',
                            PrintLeft (COALESCE (l_name4, ' '), l_len4));
                    l_index3 := l_index3 + l_len3;
                    l_index4 := l_index4 + l_len4;
                    l_address3 := SUBSTR (p_address, l_index3, l_len3);
                    l_name4 := SUBSTR (p_pib, l_index4, l_len4);
                    l_buff := l_buff || l_buff3;
                    i3 := i3 + 1;
                END LOOP;
            END;

            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE TabFooter
        IS
            v_index   PLS_INTEGER DEFAULT 64;
            v_text    VARCHAR2 (21);
        BEGIN
            l_sum_text := '(' || UPPER (sum_to_text (l_sum_tab)) || ')';
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            l_footer_tab,
                                            '<RN_IND>',
                                            PrintCenter (TO_CHAR (l_rn_rep),
                                                         3)),
                                        '<SUM_TEXT1_TAB>',
                                        PrintLeft (
                                            SUBSTR (l_sum_text,
                                                    1,
                                                    CT_SUM_TEXT_TAB_LENGTH),
                                            CT_SUM_TEXT_TAB_LENGTH + 1)),
                                    '<SUM_TEXT2_TAB>',
                                    PrintLeft (
                                        COALESCE (
                                            SUBSTR (
                                                l_sum_text,
                                                CT_SUM_TEXT_TAB_LENGTH + 1,
                                                CT_SUM_TEXT_TAB_LENGTH),
                                            ' '),
                                        CT_SUM_TEXT_TAB_LENGTH)),
                                '<SUM_TEXT1_RTAB>',
                                PrintLeft (
                                    SUBSTR (l_sum_text,
                                            1,
                                            CT_SUM_RTAB_LENGTH          /*27*/
                                                              ),
                                    CT_SUM_RTAB_LENGTH)),
                            '<SUM_TEXT2_RTAB>',
                            PrintLeft (
                                COALESCE (
                                    SUBSTR (l_sum_text,                 /*28*/
                                            CT_SUM_RTAB_LENGTH + 1,
                                            CT_SUM_RTAB_LENGTH),
                                    ' '),
                                CT_SUM_RTAB_LENGTH)),
                        '<SUM_TEXT3_RTAB>',
                        PrintLeft (
                            COALESCE (
                                SUBSTR (l_sum_text,
                                        CT_SUM_RTAB_LENGTH * 2 + 1,
                                        CT_SUM_RTAB_LENGTH),
                                ' '),
                            CT_SUM_RTAB_LENGTH)),
                    '<SUM_TAB>',
                    PrintRight (
                        TRIM (TO_CHAR (l_sum_tab, '999999999990.00')),
                        15));
            v_text := SUBSTR (l_sum_text, v_index, 21);

            WHILE v_text IS NOT NULL
            LOOP
                l_buff :=
                       l_buff
                    || l_footer_tab_end
                    || v_text
                    || CHR (13)
                    || CHR (10);
                v_index := v_index + 21;
                v_text := SUBSTR (l_sum_text, v_index, 21);
            END LOOP;

            l_buff :=
                   l_buff
                || l_footer_tab_end
                || CHR (13)
                || CHR (10)
                || REPLACE (
                       REPLACE (l_footer_doc,
                                '<ORG_HEAD>',
                                PrintLeft (l_org_head, 30)),
                       '<ORG_BUH>',
                       PrintLeft (l_org_buh, 30));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT CASE
                   WHEN pr_tp = 'A'
                   THEN
                       SUBSTR (
                              ''                 --' КАТЕГОРІЯ ' || t.npt_code
                           || ' ПЕРІОД '
                           ||                                           -- l_per_num
                              (SELECT COUNT (1)
                                 FROM v_payroll p2
                                WHERE     p2.pr_month = pr.pr_month
                                      AND p2.com_org = pr.com_org
                                      AND p2.pr_npc = pr.pr_npc
                                      AND p2.pr_pay_tp = pr.pr_pay_tp
                                      ---and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                      AND p2.pr_create_dt <= pr.pr_create_dt)
                           || ' '
                           || c.npc_name,
                           1,
                           79)
                   ELSE
                       ''
               END,
                  ' ПЕРІОД '
               ||                                                     /*pr_per_num*/
                                                                        -- l_per_num
                  (SELECT COUNT (1)
                     FROM v_payroll p2
                    WHERE     p2.pr_month = pr.pr_month
                          AND p2.com_org = pr.com_org
                          AND p2.pr_npc = pr.pr_npc
                          AND p2.pr_pay_tp = pr.pr_pay_tp
                          --and p2.pr_tp = pr.pr_tp  --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                          AND p2.pr_create_dt <= pr.pr_create_dt),
               npc_name,
               npc_code,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,
               org_code                        --  #89720 Виправити назву УСЗН
                       ,                                            /*tools.*/
               get_acc_setup_pib (1, 1, com_org),                   /*tools.*/
               get_acc_setup_pib (0, 1, com_org)
          /* , (SELECT UPPER(z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn)
              FROM uss_ndi.v_ndi_functionary z
              WHERE z.fnc_tp = 'A'
                AND z.history_status = 'A'
                AND z.com_org = pr.com_org
              fetch first row only) as main_buch
           , (SELECT z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn
              FROM uss_ndi.v_ndi_functionary z
              WHERE z.fnc_tp = 'B'
                AND z.history_status = 'A'
                AND z.com_org = pr.com_org
              fetch first row only) as head_department*/
          INTO l_a_pr_name,
               l_a_per_num,
               l_npc_name,
               l_npc_code,
               l_org_name,
               l_org_code,
               l_org_buh,
               l_org_head
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr.pr_npc
               JOIN v_opfu op ON org_id = com_org
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id;

        FOR rec
            IN (SELECT grp_key,
                       post_name,
                          ROW_NUMBER ()
                              OVER (
                                  ORDER BY post_name, supl_desc_dt, dpp_name)
                       || '/'
                       || prs_num
                           AS accomp_desc_num,
                       supl_desc_dt,
                       supl_month,
                       dpp_name,
                       dpp_info,
                       dpp_iban,
                       bank_name,
                       bank_code,
                       bank_mfo,
                       tot_sum,
                       rows_cnt,
                       ROW_NUMBER ()
                           OVER (ORDER BY post_name, supl_desc_dt, dpp_name)
                           AS grp_rn,
                       /*count() over()*/
                       CEIL ((rows_cnt - 5) / l_page_height) + 1
                           AS grp_cnt
                  FROM (  SELECT (   s.prs_index
                                  || '/'
                                  || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                  || '/'
                                  || COALESCE (
                                         TO_CHAR (s.prs_dpp),
                                            s.prs_ln
                                         || ' '
                                         || s.prs_fn
                                         || ' '
                                         || s.prs_mn))
                                     AS grp_key,
                                 MAX (cn.ncn_name)
                                     AS post_name,
                                 MAX (s.prs_num)
                                     AS prs_num,
                                 MAX (TO_CHAR (r.Pr_Create_Dt, 'DD\MM\YYYY'))
                                     AS supl_desc_dt,
                                 --  #91566 MAX(to_char(r.Pr_Create_Dt, 'MM')||'-й місяць '||to_char(r.Pr_Create_Dt, 'YYYY')) AS supl_month,
                                 MAX (
                                        TO_CHAR (r.Pr_month, 'MM')
                                     || '-й місяць '
                                     || TO_CHAR (r.Pr_month, 'YYYY'))
                                     AS supl_month,
                                 COALESCE (
                                     MAX (pp.dpp_name),
                                     MAX (
                                            s.prs_ln
                                         || ' '
                                         || s.prs_fn
                                         || ' '
                                         || s.prs_mn))
                                     AS dpp_name,
                                 CASE
                                     WHEN MAX (dpp_id) IS NULL
                                     THEN
                                         MAX (prs_address)
                                     ELSE
                                         MAX (pp.dpp_address)
                                 END
                                     AS dpp_info,
                                 CASE
                                     WHEN MAX (dpp_id) IS NULL
                                     THEN
                                         MAX (prs_account)
                                     ELSE
                                         MAX (ppa.dppa_account)
                                 END
                                     AS dpp_iban,
                                 MAX (b.nb_name)
                                     AS bank_name,
                                 MAX (s.prs_inn) /* #93043 io 20231020 зі слів ТН MAX(b.nb_num)*/
                                     AS bank_code,
                                 MAX (b.nb_mfo)
                                     AS bank_mfo,
                                 COUNT (
                                     DISTINCT
                                            s.prs_index
                                         || '/'
                                         || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                         || '/'
                                         || COALESCE (
                                                TO_CHAR (s.prs_dpp),
                                                   s.prs_ln
                                                || ' '
                                                || s.prs_fn
                                                || ' '
                                                || s.prs_mn)
                                         || '#'
                                         || uss_person.api$sc_tools.GET_PIB (
                                                pc.pc_sc)
                                         || '#'
                                         || a.pa_num
                                         || '#'
                                         || CASE
                                                WHEN prs_address IS NOT NULL
                                                THEN
                                                       prs_index
                                                    || ', '
                                                    || prs_address
                                                ELSE
                                                    uss_person.api$sc_tools.get_address (
                                                        pc.pc_sc,
                                                        2)
                                            END
                                         -- ||'#'|| dn_in_doc_num ||'#'|| dn_out_doc_num ||'#'|| dn_out_doc_dt
                                         || '#'
                                         || (SELECT MAX (
                                                           dn_in_doc_num
                                                        || '#'
                                                        || dn_out_doc_num
                                                        || '#'
                                                        || dn_out_doc_dt)
                                               FROM uss_esr.v_ac_detail ad
                                                    JOIN uss_esr.v_deduction dn
                                                        ON dn.dn_id = ad.acd_dn
                                              WHERE ad.acd_prsd = d.prsd_id))
                                     AS rows_cnt,
                                 (   TO_CHAR (SUM (d.prsd_sum),
                                              'FM9G999G999G999G999G990D00',
                                              'NLS_NUMERIC_CHARACTERS=''.''''')
                                  || ' '
                                  || uss_esr.dnet$payment_reports.sum_in_words (
                                         SUM (d.prsd_sum),
                                         'гривня',
                                         'гривні',
                                         'гривень',
                                         'коп.'))
                                     AS tot_sum
                            FROM uss_esr.v_pr_sheet s
                                 JOIN uss_esr.v_payroll r
                                     ON (r.pr_id = s.prs_pr)
                                 LEFT JOIN uss_ndi.v_ndi_post_office po
                                     ON     po.npo_index = s.prs_index
                                        AND po.history_status = 'A'
                                        AND COALESCE (po.npo_kaot,
                                                      s.prs_kaot,
                                                      -1) =
                                            COALESCE (s.prs_kaot, -1)
                                        AND COALESCE (po.npo_org, r.com_org) =
                                            TO_CHAR (r.com_org)
                                 LEFT JOIN uss_ndi.v_ndi_comm_node cn
                                     ON     cn.ncn_id = po.npo_ncn
                                        AND cn.history_status = 'A'
                                        AND SUBSTR (
                                                TO_CHAR (
                                                    COALESCE (cn.ncn_org,
                                                              r.com_org)),
                                                1,
                                                3) =
                                            SUBSTR (TO_CHAR (r.com_org), 1, 3)
                                 LEFT JOIN uss_ndi.v_ndi_pay_person pp
                                     ON pp.dpp_id = s.prs_dpp
                                 LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                                     ON     ppa.dppa_dpp = s.prs_dpp
                                        AND ppa.history_status = 'A'
                                        AND ppa.dppa_is_main = 1
                                 LEFT JOIN uss_ndi.v_ndi_bank b
                                     ON b.nb_id =
                                        COALESCE (ppa.dppa_nb, prs_nb)
                                 LEFT JOIN uss_esr.v_pr_sheet_detail d
                                     ON     d.prsd_prs_dn = s.prs_id
                                        AND d.prsd_pr = p_pr_id
                                        AND d.prsd_prs_dn IS NOT NULL
                                 JOIN uss_esr.v_personalcase pc
                                     ON (pc.pc_id = d.prsd_pc)
                                 JOIN uss_esr.v_pc_account a
                                     ON a.pa_id = d.prsd_pa
                           /*     io 20230911           join uss_esr.v_ac_detail ad on ad.acd_prsd = d.prsd_id
                                           join uss_esr.v_deduction dn on dn.dn_id = ad.acd_dn*/
                           WHERE     s.prs_pr = TO_CHAR (p_pr_id)
                                 AND COALESCE (s.prs_st, 'NULL') != 'PP'
                                 /*and prs_tp in ('AP', 'ABP', 'ABU', 'PMT', 'AUU')*/
                                 AND prs_tp IN (p_prs_tp)
                        GROUP BY    s.prs_index
                                 || '/'
                                 || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                 || '/'
                                 || COALESCE (
                                        TO_CHAR (s.prs_dpp),
                                           s.prs_ln
                                        || ' '
                                        || s.prs_fn
                                        || ' '
                                        || s.prs_mn))
                 WHERE 1 = 1)
        LOOP
            DBMS_OUTPUT.put_line (1111);
            l_org_id := 0;
            l_prs_index := NULL;
            l_row_num := 0;
            l_page_cnt := rec.grp_cnt;

            PageHeader;
            DBMS_OUTPUT.put_line (2222);
            TabHeader (p_ORG_NAME     => l_org_name,
                       p_ORG_CODE     => l_org_code,
                       p_num          => rec.accomp_desc_num,
                       p_SUPL_DATE    => rec.supl_desc_dt,
                       p_DPP_NAME     => rec.dpp_name,
                       p_DPP_INFO     => rec.dpp_info,
                       p_DPP_IBAN     => rec.dpp_iban,
                       p_BANK_NAME    => rec.bank_name,
                       p_BANK_MFO     => rec.bank_mfo,
                       p_BANK_CODE    => rec.bank_code,
                       p_SUPL_MONTH   => rec.supl_month,
                       p_PAGE_NUM     => rec.grp_rn,
                       p_PAGE_CNT     => rec.grp_cnt);

            FOR rr
                IN (SELECT ROW_NUMBER () OVER (ORDER BY pib)
                               AS num,                      --Порядковий номер
                           pib
                               AS pib,         --Прізвище, ім’я та по батькові
                           pa_num
                               AS acc_num, --Номер особового рахунка (пенсійного посвідчення)
                           tot_sum, ---to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum, --Сума, що підлягає перерахуванню
                           address,
                           --dn_in_doc_num as dn_in_num,
                            (SELECT MAX (dn_in_doc_num)
                               FROM uss_esr.v_ac_detail  ad
                                    JOIN uss_esr.v_deduction dn
                                        ON dn.dn_id = ad.acd_dn
                              WHERE ad.acd_prsd = x_prsd_id)
                               AS dn_in_num,
                           NULL
                               AS dn_out_num,
                           --rpad(dn_out_doc_num, 28, ' ') || to_char(dn_out_doc_dt, 'dd\mm\yyyy') as dn_out_num2
                            (SELECT MAX (
                                           RPAD (dn_out_doc_num, 28, ' ')
                                        || TO_CHAR (dn_out_doc_dt,
                                                    'dd\mm\yyyy'))
                               FROM uss_esr.v_ac_detail  ad
                                    JOIN uss_esr.v_deduction dn
                                        ON dn.dn_id = ad.acd_dn
                              WHERE ad.acd_prsd = x_prsd_id)
                               AS dn_out_num2
                      FROM (  SELECT (   s.prs_index
                                      || '/'
                                      || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                      || '/'
                                      || COALESCE (
                                             TO_CHAR (s.prs_dpp),
                                                s.prs_ln
                                             || ' '
                                             || s.prs_fn
                                             || ' '
                                             || s.prs_mn))
                                         AS mds_key,
                                     uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                                         AS pib,
                                     a.pa_num,
                                     CASE
                                         WHEN prs_address IS NOT NULL
                                         THEN
                                             prs_index || ', ' || prs_address
                                         ELSE
                                             uss_person.api$sc_tools.get_address (
                                                 pc.pc_sc,
                                                 2)
                                     END
                                         AS address,
                                     -- dn_in_doc_num, dn_out_doc_num, dn_out_doc_dt,
                                     SUM (d.prsd_sum)
                                         AS tot_sum,
                                     MAX (prsd_id)
                                         AS x_prsd_id
                                FROM uss_esr.v_pr_sheet s
                                     JOIN uss_esr.v_pr_sheet_detail d
                                         ON     d.prsd_prs_dn = s.prs_id
                                            AND d.prsd_pr = p_pr_id
                                            AND d.prsd_prs_dn IS NOT NULL
                                     JOIN uss_esr.v_personalcase pc
                                         ON (pc.pc_id = d.prsd_pc)
                                     JOIN uss_esr.v_pc_account a
                                         ON a.pa_id = d.prsd_pa
                               /*     io 20230911               join uss_esr.v_ac_detail ad on ad.acd_prsd = d.prsd_id
                                               join uss_esr.v_deduction dn on dn.dn_id = ad.acd_dn*/
                               WHERE     s.prs_pr = p_pr_id
                                     AND COALESCE (s.prs_st, 'NULL') != 'PP'
                                     /*and prs_tp in ('AP', 'ABP', 'ABU', 'PMT', 'AUU')*/
                                     AND prs_tp IN (p_prs_tp)
                            GROUP BY    s.prs_index
                                     || '/'
                                     || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                     || '/'
                                     || COALESCE (
                                            TO_CHAR (s.prs_dpp),
                                               s.prs_ln
                                            || ' '
                                            || s.prs_fn
                                            || ' '
                                            || s.prs_mn),
                                     uss_person.api$sc_tools.GET_PIB (
                                         pc.pc_sc),
                                     a.pa_num,
                                     CASE
                                         WHEN prs_address IS NOT NULL
                                         THEN
                                             prs_index || ', ' || prs_address
                                         ELSE
                                             uss_person.api$sc_tools.get_address (
                                                 pc.pc_sc,
                                                 2)
                                     END--,dn_in_doc_num, dn_out_doc_num, dn_out_doc_dt
                                        ) t
                     WHERE 1 = 1 AND mds_key = rec.grp_key)
            LOOP
                IF    l_row_num >=
                        l_page_height
                      - CASE WHEN l_row_num = 0 THEN 5 ELSE 0 END
                   OR     rec.rows_cnt - 2 <=
                          (l_page_num - 1) * l_page_height + 5 + l_row_num
                      AND l_row_num > 1
                THEN
                    DBMS_OUTPUT.put_line (7777);

                    PageHeader;
                /*          TabHeader(p_ORG_NAME  => l_org_name,
                                    p_ORG_CODE  => l_org_code,
                                    p_SUPL_MONTH  => l_supl_month,
                                    p_PAGE_NUM    => l_page_num
                                   );*/
                --l_row_num := 0;
                END IF;

                DBMS_OUTPUT.put_line (
                       rr.num
                    || '-'
                    || rr.dn_out_num2
                    || '-'
                    || rr.pib
                    || '-'
                    || rr.address);
                TabBody (p_NUM           => rr.num,
                         p_PC_NUM        => rr.acc_num,
                         p_pp_sum        => rr.tot_sum,
                         p_pib           => rr.pib,
                         p_address       => rr.address,
                         p_DN_IN_NUM     => rr.dn_in_num,
                         p_DN_OUT_NUM    => rr.dn_out_num,
                         p_DN_OUT_NUM2   => rr.dn_out_num2);
            END LOOP;

            TabFooter;
        END LOOP;

        --
        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "СПИСОК сум, вiдрахованих  на користь"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "СПИСОК сум, вiдрахованих  на користь": '
                || ', n='
                || TO_CHAR (n)
                || ' '
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildAccrualList_R2;

    --  4. Список по держутриманням (перерахованих)
    PROCEDURE BuildAccrualList_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        ---p_org_id in payroll.com_org%type,
        p_rpt      IN OUT NOCOPY BLOB)
    IS
        p_asopd                  VARCHAR2 (10) := '';
        ---l_org_id     payroll.com_org%type;
        l_buff                   VARCHAR2 (32767);
        l_buff2                  VARCHAR2 (32767);
        l_pr_start_dt            payroll.pr_start_dt%TYPE;
        l_org_name               v_opfu.org_name%TYPE;
        l_org_code               v_opfu.org_code%TYPE;
        l_per_year               NUMBER (4);      ---nsi_period.per_year%type;
        l_per_month              NUMBER (2);     ---nsi_period.per_month%type;
        l_date_start             VARCHAR2 (10);
        l_date_stop              VARCHAR2 (10);
        l_per_num                NUMBER (14) := 1; --  Виплатний період ?????  payroll.pr_per_num%type;
        l_ved_tp                 CHAR (20);
        l_prs_num                pr_sheet.prs_num%TYPE DEFAULT 0;
        l_org_id                 v_opfu.ORG_ID%TYPE DEFAULT 0;
        l_prs_index              uss_ndi.v_ndi_post_office.npo_index%TYPE DEFAULT NULL;
        l_rn_rep                 PLS_INTEGER DEFAULT 0;
        l_sum_tab                NUMBER;
        l_sum_text               VARCHAR2 (512);
        n                        NUMBER := 1;
        v_address_1              VARCHAR2 (100);
        v_address_2              VARCHAR2 (100);
        l_str_1                  VARCHAR2 (40);
        l_str_2                  VARCHAR2 (40);
        l_str_3                  VARCHAR2 (40);
        l_org_head               VARCHAR2 (40);
        l_org_buh                VARCHAR2 (40);

        v_count                  NUMBER;
        v_instr                  NUMBER;
        l_a_pr_name              VARCHAR2 (100);
        l_a_per_num              VARCHAR2 (20) := 1; --  Виплатний період ?????
        l_npc_name               VARCHAR2 (100);
        l_npc_code               VARCHAR2 (100);
        --l_page_width number := 134;
        --
        Ct_pnf_pib_LENGTH        INTEGER := 40;
        CT_ADDRESS_LENGTH        INTEGER := 40;
        CT_PASSPORT_LENGTH       INTEGER := 15                          /*10*/
                                              ;       --  різні довідки і т.д.
        CT_OPFU_LENGTH           INTEGER := 75;
        CT_CNTR_LENGTH           INTEGER := 28;
        CT_SUM_TEXT_TAB_LENGTH   INTEGER := 103;
        CT_SUM_RTAB_LENGTH       INTEGER := 26;
        --
        l_header_tab             VARCHAR2 (32767)
            :=    '  Код району <ORG_CODE>   Орган, що здiйснює виплату : <ORG_NAME>'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               ||                          --#accomp_desc_num#  #supl_desc_dt#
                  '                             СПИСОК No   <ACCOMP_DESC_NUM>                   Дата видачi <SUPL_DATE> р.'
               || CHR (13)
               || CHR (10)
               || '                     сум, перерахованих  на користь'
               || CHR (13)
               || CHR (10)
               || '<DPP_NAME>'
               || CHR (13)
               || CHR (10)
               || '<DPP_INFO>'
               || CHR (13)
               || CHR (10)
               || '    розрахунковий рахунок N <DPP_IBAN>'
               || CHR (13)
               || CHR (10)
               || '    у <BANK_NAME>'
               || CHR (13)
               || CHR (10)
               ||                               -- особовий рахунок органiзацiї
                  '               МФО <BANK_MFO>  Код <BANK_CODE>   по  ДЕРЖБЮДЖЕТ (СУБВ.)'
               || CHR (13)
               || CHR (10)
               || '                         за  <SUPL_MONTH> р.'
               || CHR (13)
               || CHR (10)
               || '                                                      Аркуш  <PAGE_NUM> (<PAGE_CNT>)'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦                                        ¦            ¦  Сума    ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ No  ¦      Прiзвище, iм'' я, по батьковi      ¦   Номер    ¦перераху- ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ п/п ¦                                        ¦ особового  ¦  вання   ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦     ¦                                        ¦  рахунку   ¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1  ¦                     2                  ¦      3     ¦     4    ¦'
               || CHR (13)
               || CHR (10)--'  +-----+----------+----------------------------------------+----------------------------------------+------------+----------+' || chr(13) || chr(10)
                          ;
        l_header_page            VARCHAR2 (32767)
            :=    '                                                      Аркуш  <PAGE_NUM> (<PAGE_CNT>)'
               || CHR (13)
               || CHR (10)
               || '  +-----+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1  ¦                     2                  ¦      3     ¦     4    ¦'
               || CHR (13)
               || CHR (10);

        l_body_tab               VARCHAR2 (32767)
            :=    '  +-----+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦<NN>¦<PIB_ADDRESS1>¦<PC_NUM>¦<PP_SUM>¦'
               || CHR (13)
               || CHR (10);
        l_body_line2             VARCHAR2 (1000)
            :=    '  ¦     ¦<PIB_ADDRESS2>¦            ¦          ¦'
               || CHR (13)
               || CHR (10);
        l_body_line3             VARCHAR2 (1000)
            :=    '  ¦     ¦<PIB_ADDRESS3>¦            ¦          ¦'
               || CHR (13)
               || CHR (10);

        l_footer_tab             VARCHAR2 (32767)
            :=    '  +-----+----------------------------------------+------------+----------+'
               || CHR (13)
               || CHR (10)
               || '                                                  Разом:   <SUM_TAB> '
               || CHR (13)
               || CHR (10);
        l_footer_tab_end         VARCHAR2 (32767) := '';
        l_footer_doc             VARCHAR2 (32767)
            :=    ''
               || CHR (13)
               || CHR (10)
               || '     Керiвник           ______________ <ORG_HEAD>'
               || CHR (13)
               || CHR (10)
               || '              М.П.'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     Головний бухгалтер ______________ <ORG_BUH>'
               || CHR (13)
               || CHR (10)
               || '                     (старший спецiалiст)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     Перераховано______________________________________________'
               || CHR (13)
               || CHR (10)
               || '              (найменування структурного пiдроздiлу з питань соцiального захисту населення)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     платiжним дорученням No _______ вiд _______________________'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '     Вiдповiдальна особа                          ______________   (______________)'
               || CHR (13)
               || CHR (10)
               || '                                                      (пiдпис)'
               || CHR (13)
               || CHR (10);


        l_PAGE_CNT               NUMBER;
        l_page_num               NUMBER := 0;
        l_row_num                NUMBER := 0;
        l_page_height            NUMBER := 25; -- 25 рядків таблиці. для 1-ї сторінки (з шапкою) - лише 10
        l_rep                    t_b1m_table;


        PROCEDURE PageHeader
        IS
        BEGIN
            l_buff2 :=
                   '
 -----------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CHR (12)
                || ' -----------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF                                                   /*l_row_num*/
               l_page_num = 0
            THEN
                l_buff := REPLACE (REPLACE (l_buff, CHR (12), ''), '
', '');
            ELSIF l_row_num = 0
            THEN
                l_buff := l_buff;
            ELSE
                l_buff :=
                       l_buff
                    || REPLACE (
                           REPLACE (l_header_page,
                                    '<PAGE_NUM>',
                                    PrintRight (l_page_num + 1, 5)),
                           '<PAGE_CNT>',
                           PrintRight (l_PAGE_CNT, 5));
            END IF;

            l_page_num := l_page_num + 1;
            --l_row_num := 1;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        --
        PROCEDURE TabHeader (p_ORG_NAME     IN VARCHAR2,
                             p_ORG_CODE     IN VARCHAR2,
                             p_num          IN VARCHAR2,
                             p_SUPL_DATE    IN VARCHAR2,
                             p_DPP_NAME     IN VARCHAR2,
                             p_DPP_INFO     IN VARCHAR2,
                             p_DPP_IBAN     IN VARCHAR2,
                             p_BANK_NAME    IN VARCHAR2,
                             p_BANK_MFO     IN VARCHAR2,
                             p_BANK_CODE    IN VARCHAR2,
                             p_SUPL_MONTH   IN VARCHAR2,
                             p_PAGE_NUM     IN INTEGER,
                             p_PAGE_CNT     IN INTEGER)
        IS
        BEGIN
            DBMS_OUTPUT.put_line (3333);
            l_buff := l_header_tab;
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_CODE>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_CODE, 1, 5)), 5));
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_NAME>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_NAME, 1, 40)), 40)); --
            l_buff :=
                REPLACE (l_buff,
                         '<ACCOMP_DESC_NUM>',
                         PrintLeft (TRIM (p_num), 5)); -- substr(l_npc_name,1,70)
            l_buff :=
                REPLACE (l_buff, '<SUPL_DATE>', PrintLeft (p_SUPL_DATE, 10));
            l_buff :=
                REPLACE (l_buff, '<DPP_NAME>', PrintCenter (p_DPP_NAME, 80));
            l_buff :=
                REPLACE (l_buff, '<DPP_INFO>', PrintCenter (p_DPP_INFO, 80));
            l_buff :=
                REPLACE (l_buff, '<DPP_IBAN>', PrintLeft (p_DPP_IBAN, 30));
            l_buff :=
                REPLACE (l_buff,
                         '<BANK_NAME>',
                         PrintCenter (p_BANK_NAME, 70));
            l_buff :=
                REPLACE (l_buff, '<BANK_MFO>', PrintLeft (p_BANK_MFO, 10));
            l_buff :=
                REPLACE (l_buff, '<BANK_CODE>', PrintLeft (p_BANK_CODE, 10));
            l_buff :=
                REPLACE (l_buff,
                         '<SUPL_MONTH>',
                         PrintLeft (p_SUPL_MONTH, 16));
            l_buff :=
                REPLACE (l_buff, '<PAGE_NUM>', PrintRight (p_PAGE_NUM, 5));
            l_buff :=
                REPLACE (l_buff, '<PAGE_CNT>', PrintRight (p_PAGE_CNT, 5));

            l_rn_rep := 0;
            l_sum_tab := 0;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := l_row_num + 1;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'TabHeader: '
                    || ', n='
                    || TO_CHAR (n)
                    || ' '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END;

        --
        PROCEDURE TabBody (p_NUM      IN VARCHAR2,
                           p_PC_NUM   IN VARCHAR2,
                           p_pp_sum   IN NUMBER,
                           p_pib      IN VARCHAR2 /*,
                         p_address     in varchar2,
                         p_DN_IN_NUM   in varchar2,
                         p_DN_OUT_NUM  in number,
                         p_DN_OUT_NUM2 in varchar2*/
                                                 )
        IS
            v_sum     VARCHAR2 (30)
                          := TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '9999990.00'));
            l_pib1    VARCHAR2 (255);
            l_pib2    VARCHAR2 (255);
            l_buff0   VARCHAR2 (25000);

            --
            PROCEDURE get_pnf_pib
            IS
                p1   INTEGER := INSTR (p_pib, ' ', 1);
                p2   INTEGER := INSTR (p_pib, ' ', -1);
                w    INTEGER := LENGTH (p_pib);
            BEGIN
                IF LENGTH (p_pib) <= Ct_pnf_pib_LENGTH
                THEN
                    l_pib1 := p_pib;
                    l_pib2 := NULL;
                ELSE
                    l_pib1 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, 1, p2 - 1)
                            ELSE
                                SUBSTR (p_pib, 1, p1 - 1)
                        END;
                    l_pib2 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, p2 + 1, w - p2)
                            ELSE
                                SUBSTR (p_pib, p1 + 1, w - p1)
                        END;

                    IF GREATEST (LENGTH (l_pib1), LENGTH (l_pib2)) >
                       Ct_pnf_pib_LENGTH
                    THEN
                        l_pib1 := SUBSTR (p_pib, 1, Ct_pnf_pib_LENGTH);
                        l_pib2 :=
                            SUBSTR (p_pib,
                                    Ct_pnf_pib_LENGTH + 1,
                                    Ct_pnf_pib_LENGTH);
                    END IF;
                END IF;
            --case when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,1,Ct_pnf_pib_LENGTH);
            --when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,Ct_pnf_pib_LENGTH + 1,Ct_pnf_pib_LENGTH);
            END;
        BEGIN
            l_rn_rep := l_rn_rep + 1;
            get_pnf_pib;

            l_str_1 := TRIM (l_pib1);

            IF l_pib2 IS NOT NULL
            THEN
                l_str_2 := TRIM (l_pib2);
            ---l_str_3 := trim(v_address_1); l_buff0 := '';
            ELSE
                l_str_2 := TRIM (v_address_1);
            --- l_str_3 := trim(v_address_2);
            ---l_buff := l_buff || l_buff2;
            END IF;

            IF l_str_2 IS NOT NULL
            THEN
                l_buff0 :=
                    REPLACE (
                        l_body_line2,
                        '<PIB_ADDRESS2>',
                        PrintLeft (COALESCE (l_str_2, ' '),
                                   Ct_pnf_pib_LENGTH));
            ELSE
                l_buff0 := '';
            END IF;

            l_buff :=                             /*REPLACE(REPLACE(REPLACE(*/
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (l_body_tab,
                                                '<NN>',
                                                PrintLeft (p_num, 5)),
                                       /*      '<DN_IN_NUM>', PrintLeft(p_DN_IN_NUM,10)),
                                             '<DN_OUT_NUM>', PrintLeft(p_DN_OUT_NUM,40)),
                                             '<DN_OUT_NUM2>', PrintLeft(p_DN_OUT_NUM2,40)),*/
                                       '<PIB_ADDRESS1>',
                                       PrintLeft (COALESCE (l_str_1, ' '),
                                                  40)),
                                   '<PIB_ADDRESS2>',
                                   PrintLeft (COALESCE (l_str_2, ' '), 40)),
                               '<PIB_ADDRESS3>',
                               PrintLeft (COALESCE (l_str_3, ' '), 40)),
                           '<PC_NUM>',
                           PrintLeft (p_PC_NUM, 12)),
                       '<PP_SUM>',
                       PrintRight (v_sum, 10))
                || l_buff0;

            /*declare
              l_index3    integer := CT_ADDRESS_LENGTH + CT_ADDRESS_LENGTH + 1;
              l_len3      integer := CT_ADDRESS_LENGTH;
              l_max_line3 integer := 3;
              i3          integer := 0;
              l_address3  varchar2(255) := substr(p_address, l_index3, l_len3);
              l_buff3     varchar2(5000);
              --
              l_index4    integer := Ct_pnf_pib_LENGTH + Ct_pnf_pib_LENGTH + 1;
              l_len4      integer := Ct_pnf_pib_LENGTH;
              l_name4     varchar2(255) := substr(p_pib, l_index4, l_len4);
            begin
              while (l_address3 is not null or l_name4 is not null) and i3 < l_max_line3
                loop
                  l_buff3 := replace(replace(l_body_line3,
                    '<ADDRESS3>', PrintLeft(coalesce(l_address3, ' '),l_len3)),
                    '<pib3>', PrintLeft(coalesce(l_name4, ' '),l_len4));
                  l_index3   := l_index3 + l_len3;
                  l_index4   := l_index4 + l_len4;
                  l_address3 := substr(p_address, l_index3, l_len3);
                  l_name4    := substr(p_pib, l_index4, l_len4);
                  l_buff := l_buff || l_buff3;
                  i3:= i3 + 1;
                end loop;
            end;*/

            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE TabFooter
        IS
            v_index   PLS_INTEGER DEFAULT 64;
            v_text    VARCHAR2 (21);
        BEGIN
            l_sum_text := '(' || UPPER (sum_to_text (l_sum_tab)) || ')';
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            l_footer_tab,
                                            '<RN_IND>',
                                            PrintCenter (TO_CHAR (l_rn_rep),
                                                         3)),
                                        '<SUM_TEXT1_TAB>',
                                        PrintLeft (
                                            SUBSTR (l_sum_text,
                                                    1,
                                                    CT_SUM_TEXT_TAB_LENGTH),
                                            CT_SUM_TEXT_TAB_LENGTH + 1)),
                                    '<SUM_TEXT2_TAB>',
                                    PrintLeft (
                                        COALESCE (
                                            SUBSTR (
                                                l_sum_text,
                                                CT_SUM_TEXT_TAB_LENGTH + 1,
                                                CT_SUM_TEXT_TAB_LENGTH),
                                            ' '),
                                        CT_SUM_TEXT_TAB_LENGTH)),
                                '<SUM_TEXT1_RTAB>',
                                PrintLeft (
                                    SUBSTR (l_sum_text,
                                            1,
                                            CT_SUM_RTAB_LENGTH          /*27*/
                                                              ),
                                    CT_SUM_RTAB_LENGTH)),
                            '<SUM_TEXT2_RTAB>',
                            PrintLeft (
                                COALESCE (
                                    SUBSTR (l_sum_text,                 /*28*/
                                            CT_SUM_RTAB_LENGTH + 1,
                                            CT_SUM_RTAB_LENGTH),
                                    ' '),
                                CT_SUM_RTAB_LENGTH)),
                        '<SUM_TEXT3_RTAB>',
                        PrintLeft (
                            COALESCE (
                                SUBSTR (l_sum_text,
                                        CT_SUM_RTAB_LENGTH * 2 + 1,
                                        CT_SUM_RTAB_LENGTH),
                                ' '),
                            CT_SUM_RTAB_LENGTH)),
                    '<SUM_TAB>',
                    PrintRight (
                        TRIM (TO_CHAR (l_sum_tab, '999999999990.00')),
                        15));
            v_text := SUBSTR (l_sum_text, v_index, 21);

            WHILE v_text IS NOT NULL
            LOOP
                l_buff :=
                       l_buff
                    || l_footer_tab_end
                    || v_text
                    || CHR (13)
                    || CHR (10);
                v_index := v_index + 21;
                v_text := SUBSTR (l_sum_text, v_index, 21);
            END LOOP;

            l_buff :=
                   l_buff
                || l_footer_tab_end
                || CHR (13)
                || CHR (10)
                || REPLACE (
                       REPLACE (l_footer_doc,
                                '<ORG_HEAD>',
                                PrintLeft (l_org_head, 30)),
                       '<ORG_BUH>',
                       PrintLeft (l_org_buh, 30));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT CASE
                   WHEN pr_tp = 'A'
                   THEN
                       SUBSTR (
                              ''                 --' КАТЕГОРІЯ ' || t.npt_code
                           || ' ПЕРІОД '
                           ||                                           -- l_per_num
                              (SELECT COUNT (1)
                                 FROM v_payroll p2
                                WHERE     p2.pr_month = pr.pr_month
                                      AND p2.com_org = pr.com_org
                                      AND p2.pr_npc = pr.pr_npc
                                      AND p2.pr_pay_tp = pr.pr_pay_tp
                                      ---and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                      AND p2.pr_create_dt <= pr.pr_create_dt)
                           || ' '
                           || c.npc_name,
                           1,
                           79)
                   ELSE
                       ''
               END,
                  ' ПЕРІОД '
               ||                                                     /*pr_per_num*/
                                                                        -- l_per_num
                  (SELECT COUNT (1)
                     FROM v_payroll p2
                    WHERE     p2.pr_month = pr.pr_month
                          AND p2.com_org = pr.com_org
                          AND p2.pr_npc = pr.pr_npc
                          AND p2.pr_pay_tp = pr.pr_pay_tp
                          --and p2.pr_tp = pr.pr_tp  --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                          AND p2.pr_create_dt <= pr.pr_create_dt),
               npc_name,
               npc_code,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,
               org_code                        --  #89720 Виправити назву УСЗН
                       ,
               (SELECT UPPER (z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn)
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'A'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS main_buch,
               (SELECT z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'B'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS head_department
          INTO l_a_pr_name,
               l_a_per_num,
               l_npc_name,
               l_npc_code,
               l_org_name,
               l_org_code,
               l_org_buh,
               l_org_head
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr.pr_npc
               JOIN v_opfu op ON org_id = com_org
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id;

        FOR rec
            IN (SELECT grp_key,
                       post_name,
                          ROW_NUMBER ()
                              OVER (
                                  ORDER BY post_name, supl_desc_dt, dpp_name)
                       || '/'
                       || prs_num
                           AS accomp_desc_num,
                       supl_desc_dt,
                       supl_month,
                       dpp_name,
                       dpp_info,
                       dpp_iban,
                       bank_name,
                       bank_code,
                       bank_mfo,
                       tot_sum,
                       rows_cnt,
                       ROW_NUMBER ()
                           OVER (ORDER BY post_name, supl_desc_dt, dpp_name)
                           AS grp_rn,
                       --count(1) over() AS grp_cnt
                       CEIL ((rows_cnt - 5) / l_page_height) + 1
                           AS grp_cnt
                  FROM (  SELECT (   s.prs_index
                                  || '/'
                                  || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                  || '/'
                                  || COALESCE (
                                         TO_CHAR (s.prs_dpp),
                                            s.prs_ln
                                         || ' '
                                         || s.prs_fn
                                         || ' '
                                         || s.prs_mn))
                                     AS grp_key,
                                 MAX (cn.ncn_name)
                                     AS post_name,
                                 MAX (s.prs_num)
                                     AS prs_num,
                                 MAX (TO_CHAR (r.Pr_Create_Dt, 'DD\MM\YYYY'))
                                     AS supl_desc_dt,
                                 --  #91566 MAX(to_char(r.Pr_Create_Dt, 'MM')||'-й місяць '||to_char(r.Pr_Create_Dt, 'YYYY')) AS supl_month,
                                 MAX (
                                        TO_CHAR (r.Pr_month, 'MM')
                                     || '-й місяць '
                                     || TO_CHAR (r.Pr_month, 'YYYY'))
                                     AS supl_month,
                                 COALESCE (
                                     MAX (pp.dpp_name),
                                     MAX (
                                            s.prs_ln
                                         || ' '
                                         || s.prs_fn
                                         || ' '
                                         || s.prs_mn))
                                     AS dpp_name,
                                 CASE
                                     WHEN MAX (dpp_id) IS NULL
                                     THEN
                                         MAX (prs_address)
                                     ELSE
                                         MAX (pp.dpp_address)
                                 END
                                     AS dpp_info,
                                 CASE
                                     WHEN MAX (dpp_id) IS NULL
                                     THEN
                                         MAX (prs_account)
                                     ELSE
                                         MAX (ppa.dppa_account)
                                 END
                                     AS dpp_iban,
                                 MAX (b.nb_name)
                                     AS bank_name,
                                 MAX (s.prs_inn) /* #93043 io 20231020 зі слів ТН MAX(b.nb_num)*/
                                     AS bank_code,
                                 MAX (b.nb_mfo)
                                     AS bank_mfo,
                                 COUNT (
                                     DISTINCT
                                            s.prs_index
                                         || '/'
                                         || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                         || '/'
                                         || COALESCE (
                                                TO_CHAR (s.prs_dpp),
                                                   s.prs_ln
                                                || ' '
                                                || s.prs_fn
                                                || ' '
                                                || s.prs_mn)
                                         || '#'
                                         || uss_person.api$sc_tools.GET_PIB (
                                                pc.pc_sc)
                                         || '#'
                                         || a.pa_num)
                                     AS rows_cnt,
                                 (   TO_CHAR (SUM (d.prsd_sum),
                                              'FM9G999G999G999G999G990D00',
                                              'NLS_NUMERIC_CHARACTERS=''.''''')
                                  || ' '
                                  || uss_esr.dnet$payment_reports.sum_in_words (
                                         SUM (d.prsd_sum),
                                         'гривня',
                                         'гривні',
                                         'гривень',
                                         'коп.'))
                                     AS tot_sum
                            FROM uss_esr.v_pr_sheet s
                                 JOIN uss_esr.v_payroll r
                                     ON (r.pr_id = s.prs_pr)
                                 LEFT JOIN uss_ndi.v_ndi_post_office po
                                     ON     po.npo_index = s.prs_index
                                        AND po.history_status = 'A'
                                        AND COALESCE (po.npo_kaot,
                                                      s.prs_kaot,
                                                      -1) =
                                            COALESCE (s.prs_kaot, -1)
                                        AND COALESCE (po.npo_org, r.com_org) =
                                            TO_CHAR (r.com_org)
                                 LEFT JOIN uss_ndi.v_ndi_comm_node cn
                                     ON     cn.ncn_id = po.npo_ncn
                                        AND cn.history_status = 'A'
                                        AND SUBSTR (
                                                TO_CHAR (
                                                    COALESCE (cn.ncn_org,
                                                              r.com_org)),
                                                1,
                                                3) =
                                            SUBSTR (TO_CHAR (r.com_org), 1, 3)
                                 LEFT JOIN uss_ndi.v_ndi_pay_person pp
                                     ON pp.dpp_id = s.prs_dpp
                                 LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                                     ON     ppa.dppa_dpp = s.prs_dpp
                                        AND ppa.history_status = 'A'
                                        AND ppa.dppa_is_main = 1
                                 LEFT JOIN uss_ndi.v_ndi_bank b
                                     ON b.nb_id =
                                        COALESCE (ppa.dppa_nb, prs_nb)
                                 LEFT JOIN uss_esr.v_pr_sheet_detail d
                                     ON     d.prsd_prs_dn = s.prs_id
                                        AND d.prsd_pr = p_pr_id
                                        AND d.prsd_prs_dn IS NOT NULL
                                 /*left*/
                                 JOIN uss_esr.v_personalcase pc
                                     ON (pc.pc_id = d.prsd_pc)
                                 /*left*/
                                 JOIN uss_esr.v_pc_account a
                                     ON a.pa_id = d.prsd_pa
                           WHERE     s.prs_pr = TO_CHAR (p_pr_id)
                                 AND COALESCE (s.prs_st, 'NULL') != 'PP'
                                 /*and prs_tp in ('AP', 'ABP', 'ABU', 'PMT', 'AUU')*/
                                 AND prs_tp IN (p_prs_tp)
                        GROUP BY    s.prs_index
                                 || '/'
                                 || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                 || '/'
                                 || COALESCE (
                                        TO_CHAR (s.prs_dpp),
                                           s.prs_ln
                                        || ' '
                                        || s.prs_fn
                                        || ' '
                                        || s.prs_mn))
                 WHERE 1 = 1)
        LOOP
            DBMS_OUTPUT.put_line (1111);
            l_org_id := 0;
            l_prs_index := NULL;
            l_row_num := 0;
            l_page_cnt := rec.grp_cnt;

            PageHeader;
            DBMS_OUTPUT.put_line (2222);
            TabHeader (p_ORG_NAME     => l_org_name,
                       p_ORG_CODE     => l_org_code,
                       p_num          => rec.accomp_desc_num,
                       p_SUPL_DATE    => rec.supl_desc_dt,
                       p_DPP_NAME     => rec.dpp_name,
                       p_DPP_INFO     => rec.dpp_info,
                       p_DPP_IBAN     => rec.dpp_iban,
                       p_BANK_NAME    => rec.bank_name,
                       p_BANK_MFO     => rec.bank_mfo,
                       p_BANK_CODE    => rec.bank_code,
                       p_SUPL_MONTH   => rec.supl_month,
                       p_PAGE_NUM     => rec.grp_rn,
                       p_PAGE_CNT     => rec.grp_cnt);

            FOR rr
                IN (SELECT ROW_NUMBER () OVER (ORDER BY pib)     AS num, --Порядковий номер
                           pib                                   AS pib, --Прізвище, ім’я та по батькові
                           pa_num                                AS acc_num, --Номер особового рахунка (пенсійного посвідчення)
                           tot_sum /*,---to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum, --Сума, що підлягає перерахуванню
                           address,
                           dn_in_doc_num as dn_in_num,
                           null as dn_out_num,
                           rpad(dn_out_doc_num, 28, ' ') || to_char(dn_out_doc_dt, 'dd\mm\yyyy') as dn_out_num2*/
                      FROM (  SELECT (   s.prs_index
                                      || '/'
                                      || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                      || '/'
                                      || COALESCE (
                                             TO_CHAR (s.prs_dpp),
                                                s.prs_ln
                                             || ' '
                                             || s.prs_fn
                                             || ' '
                                             || s.prs_mn))
                                         AS mds_key,
                                     uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                                         AS pib,
                                     a.pa_num,
                                     /*  case when prs_address is not null then prs_index ||  ', ' || prs_address
                                            else uss_person.api$sc_tools.get_address(pc.pc_sc, 2)
                                       end as address,
                                       dn_in_doc_num, dn_out_doc_num, dn_out_doc_dt,*/
                                     SUM (d.prsd_sum)
                                         AS tot_sum
                                FROM uss_esr.v_pr_sheet s
                                     JOIN uss_esr.v_pr_sheet_detail d
                                         ON     d.prsd_prs_dn = s.prs_id
                                            AND d.prsd_pr = p_pr_id
                                            AND d.prsd_prs_dn IS NOT NULL
                                     JOIN uss_esr.v_personalcase pc
                                         ON (pc.pc_id = d.prsd_pc)
                                     JOIN uss_esr.v_pc_account a
                                         ON a.pa_id = d.prsd_pa
                               /*                join uss_esr.v_ac_detail ad on ad.acd_prsd = d.prsd_id
                                               join uss_esr.v_deduction dn on dn.dn_id = ad.acd_dn*/
                               WHERE     s.prs_pr = p_pr_id
                                     AND COALESCE (s.prs_st, 'NULL') != 'PP'
                                     /*and prs_tp in ('AP', 'ABP', 'ABU', 'PMT', 'AUU')*/
                                     AND prs_tp IN (p_prs_tp)
                            GROUP BY    s.prs_index
                                     || '/'
                                     || TO_CHAR (s.prs_pay_dt, 'DDMMYYYY')
                                     || '/'
                                     || COALESCE (
                                            TO_CHAR (s.prs_dpp),
                                               s.prs_ln
                                            || ' '
                                            || s.prs_fn
                                            || ' '
                                            || s.prs_mn),
                                     uss_person.api$sc_tools.GET_PIB (
                                         pc.pc_sc),
                                     a.pa_num      /*,
case when prs_address is not null then prs_index ||  ', ' || prs_address
     else uss_person.api$sc_tools.get_address(pc.pc_sc, 2)
end,
dn_in_doc_num, dn_out_doc_num, dn_out_doc_dt*/
                                             )
                     WHERE 1 = 1 AND mds_key = rec.grp_key)
            LOOP
                IF    l_row_num >=
                        l_page_height
                      - CASE WHEN l_row_num = 0 THEN 5 ELSE 0 END
                   OR     rec.rows_cnt - 5 <=
                          (l_page_num - 1) * l_page_height + 5 + l_row_num
                      AND l_row_num > 1
                THEN
                    DBMS_OUTPUT.put_line (7777);

                    PageHeader;
                /*          TabHeader(p_ORG_NAME  => l_org_name,
                                    p_ORG_CODE  => l_org_code,
                                    p_SUPL_MONTH  => l_supl_month,
                                    p_PAGE_NUM    => l_page_num
                                   );*/
                --l_row_num := 0;
                END IF;

                --dbms_output.put_line(rr.num||'-'||rr.dn_out_num2||'-'||rr.pib||'-'||rr.address);
                TabBody (p_NUM      => rr.num,
                         p_PC_NUM   => rr.acc_num,
                         p_pp_sum   => rr.tot_sum,
                         p_pib      => rr.pib /*,
                       p_address     => rr.address,
                       p_DN_IN_NUM   => rr.dn_in_num,
                       p_DN_OUT_NUM  => rr.dn_out_num,
                       p_DN_OUT_NUM2 => rr.dn_out_num2*/
                                             );
            END LOOP;

            TabFooter;
        END LOOP;

        --
        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "СПИСОК сум, перерахованих  на користь"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "СПИСОК сум, перерахованих  на користь": '
                || ', n='
                || TO_CHAR (n)
                || ' '
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildAccrualList_R1;


    -- РЕЄСТР №  **** вiдрахувань з допомог
    PROCEDURE BuildDeduction_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        ---p_org_id in payroll.com_org%type,
        p_rpt      IN OUT NOCOPY BLOB)
    IS
        p_asopd                  VARCHAR2 (10) := '';
        l_com_org                payroll.com_org%TYPE;
        l_buff                   VARCHAR2 (32767);
        l_buff2                  VARCHAR2 (32767);
        l_pr_start_dt            payroll.pr_start_dt%TYPE;
        l_org_name               v_opfu.org_name%TYPE;
        l_org_code               v_opfu.org_code%TYPE;
        l_per_year               NUMBER (4);      ---nsi_period.per_year%type;
        l_per_month              NUMBER (2);     ---nsi_period.per_month%type;
        l_date_start             VARCHAR2 (10);
        l_date_stop              VARCHAR2 (10);
        l_per_num                NUMBER (14) := 1; --  Виплатний період ?????  payroll.pr_per_num%type;
        l_ved_tp                 CHAR (20);
        l_prs_num                pr_sheet.prs_num%TYPE DEFAULT 0;
        l_org_id                 v_opfu.ORG_ID%TYPE DEFAULT 0;
        l_prs_index              uss_ndi.v_ndi_post_office.npo_index%TYPE DEFAULT NULL;
        l_rn_rep                 PLS_INTEGER DEFAULT 0;
        l_sum_tab                NUMBER;
        l_sum_text               VARCHAR2 (512);
        n                        NUMBER := 1;
        v_address_1              VARCHAR2 (100);
        v_address_2              VARCHAR2 (100);
        v_address_3              VARCHAR2 (100);
        v_address_4              VARCHAR2 (100);
        l_org_head               VARCHAR2 (40);
        l_org_buh                VARCHAR2 (40);
        l_supl_month             VARCHAR2 (40);
        v_count                  NUMBER;
        v_instr                  NUMBER;
        l_a_pr_name              VARCHAR2 (100);
        l_a_per_num              VARCHAR2 (20) := 1; --  Виплатний період ?????
        l_npc_name               VARCHAR2 (100);
        l_npc_code               VARCHAR2 (100);
        --l_page_width number := 134;
        --
        Ct_pnf_pib_LENGTH        INTEGER := 22;
        CT_ADDRESS_LENGTH        INTEGER := 25;
        CT_ORGNAME_LENGTH        INTEGER := 20;
        CT_PASSPORT_LENGTH       INTEGER := 15                          /*10*/
                                              ;       --  різні довідки і т.д.
        CT_OPFU_LENGTH           INTEGER := 75;
        CT_CNTR_LENGTH           INTEGER := 28;
        CT_SUM_TEXT_TAB_LENGTH   INTEGER := 103;
        CT_SUM_RTAB_LENGTH       INTEGER := 26;
        --
        l_page_header            VARCHAR2 (32767)
            :=    ' '
               || CHR (13)
               || CHR (10)
               ||                          --#accomp_desc_num#  #supl_desc_dt#
                  '                                                      РЕЄСТР №  <ACCOMP_DESC_NUM>'
               || CHR (13)
               || CHR (10)
               || '                                           вiдрахувань з допомог за <SUPL_MONTH> р.'
               || CHR (13)
               || CHR (10)
               || '                               Код району <ORG_CODE>    <ORG_NAME>'
               || CHR (13)
               || CHR (10)
               || /*    '<DPP_NAME>' || chr(13) || chr(10) ||
                      '<DPP_INFO>' || chr(13) || chr(10) ||
                      '    розрахунковий рахунок N <DPP_IBAN> у' || chr(13) || chr(10) ||
                      '<BANK_NAME>' || chr(13) || chr(10) || -- особовий рахунок органiзацiї
                      '               МФО <BANK_MFO>  Код <BANK_CODE>   по  ДЕРЖБЮДЖЕТ (СУБВ.)' || chr(13) || chr(10) ||
                      '                         за  <SUPL_MONTH> р.' || chr(13) || chr(10) ||*/
                  '                                                                                                                     Аркуш <PAGE_NUM>'
               || CHR (13)
               || CHR (10)
               || '  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦ No ¦Номер ¦                      ¦                         ¦          ¦                    ¦   Розрахунковий    ¦No платiж.¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ п/п¦особ. ¦   Прiзвище, iм''я,    ¦        Адреса           ¦  Сума,   ¦ Назва  органiзацiї ¦  рахунок    Банк   ¦квитанцiї,¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦рахун.¦по батьковi пенсiонера¦                         ¦ грн.коп. ¦                    ¦     МФО Код        ¦дата      ¦'
               || CHR (13)
               || CHR (10)
               || '  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1 ¦   2  ¦          3           ¦           4             ¦    5     ¦         6          ¦         7          ¦     8    ¦'
               || CHR (13)
               || CHR (10)--'  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+' || chr(13) || chr(10)
                          ;

        l_tab_header             VARCHAR2 (32767)
            :=    '                                                                                                                     Аркуш <PAGE_NUM> '
               || CHR (13)
               || CHR (10)
               || '  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1 ¦   2  ¦          3           ¦           4             ¦    5     ¦         6          ¦         7          ¦     8    ¦'
               || CHR (13)
               || CHR (10)--'  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+' || chr(13) || chr(10)
                          ;

        l_body_tab               VARCHAR2 (32767)
            :=    '  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦<NN>¦<PC_NUM>¦<PIB1>¦<ADDRESS1>¦<PP_SUM>¦<PP_ORG_NAME1>¦<IBAN>  ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PIB2>¦<ADDRESS2>¦          ¦<PP_ORG_NAME2>¦<BANK_NAME1>¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PIB3>¦<ADDRESS3>¦          ¦<PP_ORG_NAME3>¦<BANK_NAME2>¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PIB4>¦<ADDRESS4>¦          ¦<PP_ORG_NAME4>¦<BANK_NAME3>¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PIB5>¦<ADDRESS5>¦          ¦<PP_ORG_NAME5>¦<BANK_MFO>¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PIB6>¦<ADDRESS6>¦          ¦<PP_ORG_NAME6>¦<BANK_CODE>¦          ¦'
               || CHR (13)
               || CHR (10);
        l_body_line3             VARCHAR2 (1000)
            :=    '  ¦     ¦          ¦                                        ¦<PIB_ADDRESS3>¦            ¦          ¦'
               || CHR (13)
               || CHR (10);

        l_footer_tab             VARCHAR2 (32767)
            :=    '  +----+------+----------------------+-------------------------+----------+--------------------+--------------------+----------+'
               || CHR (13)
               || CHR (10)
               || '                                                                                                  Всього:     <SUM_TAB> '
               || CHR (13)
               || CHR (10);
        l_footer_tab_end         VARCHAR2 (32767) := '';
        l_footer_doc             VARCHAR2 (32767)
            :=    -- '' || chr(13) || chr(10) ||
                  '  Виконавець  <USER_PIB>'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  Начальник вiддiлу <BUCH_PIB'
               || CHR (13)
               || CHR (10)
               || '                     (старший спецiалiст)'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '  __________________'
               || CHR (13)
               || CHR (10)
               || '        (дата)'
               || CHR (13)
               || CHR (10);



        l_page_num               NUMBER := 0;
        l_row_num                NUMBER := 0;              -- лічильник блоків
        l_page_height            NUMBER := 6;       -- к-ть блоків на сторінку
        l_rep                    t_b1m_table;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_buff2 :=
                   '
 -------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CHR (12)
                || ' -------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF l_row_num <= 1
            THEN
                l_buff := REPLACE (REPLACE (l_buff, CHR (12), ''), '
', '');
            END IF;

            l_page_num := l_page_num + 1;
            l_row_num := 0;

            IF l_page_num > 1
            THEN
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                    UTL_RAW.cast_to_raw (l_buff));
            END IF;
        END;

        --
        PROCEDURE TabHeader (p_ORG_NAME     IN VARCHAR2,
                             p_ORG_CODE     IN VARCHAR2,
                             p_SUPL_MONTH   IN VARCHAR2,
                             p_PAGE_NUM     IN INTEGER)
        IS
        BEGIN
            IF p_PAGE_NUM = 1
            THEN
                l_buff := l_page_header;
            ELSE
                l_buff := l_tab_header;
            END IF;

            l_buff :=
                REPLACE (l_buff,
                         '<ORG_CODE>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_CODE, 1, 5)), 5));
            l_buff :=
                REPLACE (l_buff,
                         '<ORG_NAME>',
                         PrintLeft (TRIM (SUBSTR (p_ORG_NAME, 1, 70)), 70)); --
            l_buff :=
                REPLACE (l_buff,
                         '<ACCOMP_DESC_NUM>',
                         PrintLeft (p_pr_id, 15));
            l_buff :=
                REPLACE (l_buff,
                         '<SUPL_MONTH>',
                         PrintLeft (p_SUPL_MONTH, 16));
            l_buff :=
                REPLACE (l_buff, '<PAGE_NUM>', PrintRight (p_PAGE_NUM, 4));

            l_rn_rep := 0;
            l_sum_tab := 0;

            /*    l_buff := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_buff,
                  '<PAGE_NUM>', PrintLeft(to_char(l_page_num),10)),
                  '<ACCOMP_DESC_NUM>', PrintRight(to_char(p_num),5)),
                  '<prs_index>', PrintLeft(lpad(trim(to_char(p_prs_index,'99990')),5,'0'),6)),
                  '<ASOPD>', \*PrintLeft(nvl(to_char(p_asopd),' '),7)*\' '),
                  '<CNTR_NAME>', \*PrintLeft*\PrintRight(substr(p_cntr_name,1,CT_CNTR_LENGTH),CT_CNTR_LENGTH)),
                  '<DLVR_CODE>', PrintRight(coalesce(to_char(p_dlvr_code),' '),3)),
                  '<SUPL_DATE>', PrintRight(to_char(p_pp_date,'dd.mm.yyyy'),10)),
                  '<PP_DAY>', PrintRight(p_pp_day,2));*/
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := 0;                                 -- l_row_num + 20;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'TabHeader: '
                    || ', n='
                    || TO_CHAR (n)
                    || ' '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END;

        --
        PROCEDURE TabBody (p_NUM           IN VARCHAR2,
                           p_PC_NUM        IN VARCHAR2,
                           p_pp_sum        IN NUMBER,
                           p_pib           IN VARCHAR2,
                           p_address       IN VARCHAR2,
                           p_PP_ORG_NAME   IN VARCHAR2,
                           p_IBAN          IN VARCHAR2,
                           p_BANK_NAME     IN VARCHAR2,
                           p_BANK_MFO      IN VARCHAR2,
                           p_BANK_CODE     IN VARCHAR2)
        IS
            v_sum     VARCHAR2 (30)
                          := TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '9999990.00'));
            l_pib1    VARCHAR2 (255);
            l_pib2    VARCHAR2 (255);
            l_pib3    VARCHAR2 (255);
            l_pib4    VARCHAR2 (255);
            l_name1   VARCHAR2 (255);
            l_name2   VARCHAR2 (255);
            l_name3   VARCHAR2 (255);
            l_name4   VARCHAR2 (255);
            l_bank1   VARCHAR2 (40);
            l_bank2   VARCHAR2 (40);
            l_bank3   VARCHAR2 (40);
            l_bank4   VARCHAR2 (40);
            l_buff0   VARCHAR2 (32000);

            --
            PROCEDURE get_pnf_pib
            IS
                p1   INTEGER := INSTR (p_pib, ' ', 1);
                p2   INTEGER := INSTR (p_pib, ' ', -1);
                w    INTEGER := LENGTH (p_pib);
            BEGIN
                IF LENGTH (p_pib) <= Ct_pnf_pib_LENGTH
                THEN
                    l_pib1 := p_pib;
                    l_pib2 := NULL;
                    l_pib3 := NULL;
                ELSE
                    l_pib1 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, 1, p2 - 1)
                            ELSE
                                SUBSTR (p_pib, 1, p1 - 1)
                        END;
                    l_pib2 :=
                        CASE
                            WHEN w - p1 > p2 - 1
                            THEN
                                SUBSTR (p_pib, p2 + 1, w - p2)
                            ELSE
                                SUBSTR (p_pib, p1 + 1, w - p1)
                        END;

                    IF GREATEST (LENGTH (l_pib1), LENGTH (l_pib2)) >
                       Ct_pnf_pib_LENGTH
                    THEN
                        l_pib1 := SUBSTR (p_pib, 1, Ct_pnf_pib_LENGTH);
                        l_pib2 :=
                            SUBSTR (p_pib,
                                    Ct_pnf_pib_LENGTH + 1,
                                    Ct_pnf_pib_LENGTH);
                        l_pib3 :=
                            SUBSTR (p_pib,
                                    2 * Ct_pnf_pib_LENGTH + 1,
                                    Ct_pnf_pib_LENGTH);
                        l_pib4 :=
                            SUBSTR (p_pib,
                                    3 * Ct_pnf_pib_LENGTH + 1,
                                    Ct_pnf_pib_LENGTH);
                    END IF;
                END IF;
            --case when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,1,Ct_pnf_pib_LENGTH);
            --when w > Ct_pnf_pib_LENGTH * 2 then substr(p_pib,Ct_pnf_pib_LENGTH + 1,Ct_pnf_pib_LENGTH);
            END;
        BEGIN
            l_rn_rep := l_rn_rep + 1;
            get_pnf_pib;

            /*    if p_ind_lim_value<p_pp_sum then
                  raise_application_error(-20000, 'Знайдена пенсійна виплата, яка перевищує ліміт.
                                                   Індекс поштового зв`язку '||to_char(p_prs_index)||',
                                                   сума ліміту = '||to_char(p_ind_lim_value)||',
                                                   номер пенсійної справи '||p_pnf_number||',
                                                   сума виплати = '||v_sum);
                end if;*/

            v_count :=
                REGEXP_COUNT (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH), ',');

            IF v_count > 0
            THEN
                v_instr :=
                    INSTR (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                           ',',
                           1,
                           v_count);
            ELSE
                v_instr := 0;
            END IF;

            IF     (LENGTH (p_address) > CT_ADDRESS_LENGTH)
               AND (v_count > 0)
               AND (LENGTH (p_address) - v_instr < 30 + 1)
            THEN
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, V_INSTR), ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    V_INSTR + 1 + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            ELSE
                v_address_1 :=
                    PrintLeft (
                        COALESCE (SUBSTR (p_address, 1, CT_ADDRESS_LENGTH),
                                  ' '),
                        CT_ADDRESS_LENGTH);
                v_address_2 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    CT_ADDRESS_LENGTH + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
                v_address_3 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    2 * CT_ADDRESS_LENGTH + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
                v_address_4 :=
                    PrintLeft (
                        COALESCE (
                            SUBSTR (p_address,
                                    3 * CT_ADDRESS_LENGTH + 1,
                                    CT_ADDRESS_LENGTH),
                            ' '),
                        CT_ADDRESS_LENGTH);
            END IF;

            l_name1 :=
                PrintLeft (
                    COALESCE (SUBSTR (p_PP_ORG_NAME, 1, CT_ORGNAME_LENGTH),
                              ' '),
                    CT_ORGNAME_LENGTH);
            l_name2 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_PP_ORG_NAME,
                                CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);
            l_name3 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_PP_ORG_NAME,
                                2 * CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);
            l_name4 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_PP_ORG_NAME,
                                3 * CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);
            /*    l_name5 := PrintLeft(coalesce(substr(p_PP_ORG_NAME, 2*CT_ORGNAME_LENGTH+1, CT_ORGNAME_LENGTH), ' '),CT_ORGNAME_LENGTH);
                l_name6 := PrintLeft(coalesce(substr(p_PP_ORG_NAME, 3*CT_ORGNAME_LENGTH+1, CT_ORGNAME_LENGTH), ' '),CT_ORGNAME_LENGTH);*/
            l_bank1 :=
                PrintLeft (
                    COALESCE (SUBSTR (p_BANK_NAME, 1, CT_ORGNAME_LENGTH),
                              ' '),
                    CT_ORGNAME_LENGTH);
            l_bank2 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_BANK_NAME,
                                CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);
            l_bank3 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_BANK_NAME,
                                2 * CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);

            /*    if l_str_3 is not null then
                  l_buff0 := replace(l_body_line3, '<PIB_ADDRESS3>', PrintLeft(coalesce(l_str_3,' '),Ct_pnf_pib_LENGTH) );
                else
                  l_buff0 := '';
                end if;*/
            /*    dbms_output.put_line('l_pib2='||l_pib2) ;
                dbms_output.put_line('l_str_1='||l_str_1) ;
                dbms_output.put_line('l_str_2='||l_str_2) ;
                dbms_output.put_line('l_str_3='||l_str_3) ;
                dbms_output.put_line('v_address_1='||v_address_1) ;
                dbms_output.put_line('v_address_2='||v_address_2) ;*/

            l_buff :=
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (
                                                           REPLACE (
                                                               REPLACE (
                                                                   REPLACE (
                                                                       REPLACE (
                                                                           REPLACE (
                                                                               REPLACE (
                                                                                   REPLACE (
                                                                                       REPLACE (
                                                                                           REPLACE (
                                                                                               REPLACE (
                                                                                                   REPLACE (
                                                                                                       REPLACE (
                                                                                                           REPLACE (
                                                                                                               REPLACE (
                                                                                                                   REPLACE (
                                                                                                                       REPLACE (
                                                                                                                           REPLACE (
                                                                                                                               l_body_tab,
                                                                                                                               '<NN>',
                                                                                                                               PrintRight (
                                                                                                                                   p_num,
                                                                                                                                   4)),
                                                                                                                           '<PC_NUM>',
                                                                                                                           PrintLeft (
                                                                                                                               p_PC_NUM,
                                                                                                                               6)),
                                                                                                                       '<PP_SUM>',
                                                                                                                       PrintRight (
                                                                                                                           v_sum,
                                                                                                                           10)),
                                                                                                                   '<PIB1>',
                                                                                                                   PrintLeft (
                                                                                                                       l_pib1,
                                                                                                                       Ct_pnf_pib_LENGTH)),
                                                                                                               '<PIB2>',
                                                                                                               PrintLeft (
                                                                                                                   l_pib2,
                                                                                                                   Ct_pnf_pib_LENGTH)),
                                                                                                           '<PIB3>',
                                                                                                           PrintLeft (
                                                                                                               l_pib3,
                                                                                                               Ct_pnf_pib_LENGTH)),
                                                                                                       '<PIB4>',
                                                                                                       PrintLeft (
                                                                                                           l_pib4,
                                                                                                           Ct_pnf_pib_LENGTH)),
                                                                                                   '<PIB5>',
                                                                                                   PrintLeft (
                                                                                                       ' ',
                                                                                                       Ct_pnf_pib_LENGTH)),
                                                                                               '<PIB6>',
                                                                                               PrintLeft (
                                                                                                   ' ',
                                                                                                   Ct_pnf_pib_LENGTH)),
                                                                                           '<ADDRESS1>',
                                                                                           PrintLeft (
                                                                                               COALESCE (
                                                                                                   v_address_1,
                                                                                                   ' '),
                                                                                               CT_ADDRESS_LENGTH)),
                                                                                       '<ADDRESS2>',
                                                                                       PrintLeft (
                                                                                           COALESCE (
                                                                                               v_address_2,
                                                                                               ' '),
                                                                                           CT_ADDRESS_LENGTH)),
                                                                                   '<ADDRESS3>',
                                                                                   PrintLeft (
                                                                                       COALESCE (
                                                                                           v_address_3,
                                                                                           ' '),
                                                                                       CT_ADDRESS_LENGTH)),
                                                                               '<ADDRESS4>',
                                                                               PrintLeft (
                                                                                   COALESCE (
                                                                                       v_address_4,
                                                                                       ' '),
                                                                                   CT_ADDRESS_LENGTH)),
                                                                           '<ADDRESS5>',
                                                                           PrintLeft (
                                                                               ' ',
                                                                               CT_ADDRESS_LENGTH)),
                                                                       '<ADDRESS6>',
                                                                       PrintLeft (
                                                                           ' ',
                                                                           CT_ADDRESS_LENGTH)),
                                                                   '<PP_ORG_NAME1>',
                                                                   PrintLeft (
                                                                       COALESCE (
                                                                           l_name1,
                                                                           ' '),
                                                                       CT_ORGNAME_LENGTH)),
                                                               '<PP_ORG_NAME2>',
                                                               PrintLeft (
                                                                   COALESCE (
                                                                       l_name2,
                                                                       ' '),
                                                                   CT_ORGNAME_LENGTH)),
                                                           '<PP_ORG_NAME3>',
                                                           PrintLeft (
                                                               COALESCE (
                                                                   l_name3,
                                                                   ' '),
                                                               CT_ORGNAME_LENGTH)),
                                                       '<PP_ORG_NAME4>',
                                                       PrintLeft (
                                                           COALESCE (l_name4,
                                                                     ' '),
                                                           CT_ORGNAME_LENGTH)),
                                                   '<PP_ORG_NAME5>',
                                                   PrintLeft (
                                                       ' ',
                                                       CT_ORGNAME_LENGTH)),
                                               '<PP_ORG_NAME6>',
                                               PrintLeft (' ',
                                                          CT_ORGNAME_LENGTH)),
                                           '<IBAN>',
                                           PrintLeft (p_IBAN, 29)),
                                       '<BANK_NAME1>',
                                       PrintLeft (l_bank1, CT_ORGNAME_LENGTH)),
                                   '<BANK_NAME2>',
                                   PrintLeft (l_bank2, CT_ORGNAME_LENGTH)),
                               '<BANK_NAME3>',
                               PrintLeft (l_bank3, CT_ORGNAME_LENGTH)),
                           '<BANK_MFO>',
                           PrintLeft (p_BANK_MFO, CT_ORGNAME_LENGTH)),
                       '<BANK_CODE>',
                       PrintLeft (p_BANK_CODE, CT_ORGNAME_LENGTH))
                || l_buff0;


            l_row_num := l_row_num + 1;
            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE TabFooter
        IS
            v_index   PLS_INTEGER DEFAULT 64;
            v_text    VARCHAR2 (21);
        BEGIN
            l_sum_text := '(' || UPPER (sum_to_text (l_sum_tab)) || ')';
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            l_footer_tab,
                                            '<RN_IND>',
                                            PrintCenter (TO_CHAR (l_rn_rep),
                                                         3)),
                                        '<SUM_TEXT1_TAB>',
                                        PrintLeft (
                                            SUBSTR (l_sum_text,
                                                    1,
                                                    CT_SUM_TEXT_TAB_LENGTH),
                                            CT_SUM_TEXT_TAB_LENGTH + 1)),
                                    '<SUM_TEXT2_TAB>',
                                    PrintLeft (
                                        COALESCE (
                                            SUBSTR (
                                                l_sum_text,
                                                CT_SUM_TEXT_TAB_LENGTH + 1,
                                                CT_SUM_TEXT_TAB_LENGTH),
                                            ' '),
                                        CT_SUM_TEXT_TAB_LENGTH)),
                                '<SUM_TEXT1_RTAB>',
                                PrintLeft (
                                    SUBSTR (l_sum_text,
                                            1,
                                            CT_SUM_RTAB_LENGTH          /*27*/
                                                              ),
                                    CT_SUM_RTAB_LENGTH)),
                            '<SUM_TEXT2_RTAB>',
                            PrintLeft (
                                COALESCE (
                                    SUBSTR (l_sum_text,                 /*28*/
                                            CT_SUM_RTAB_LENGTH + 1,
                                            CT_SUM_RTAB_LENGTH),
                                    ' '),
                                CT_SUM_RTAB_LENGTH)),
                        '<SUM_TEXT3_RTAB>',
                        PrintLeft (
                            COALESCE (
                                SUBSTR (l_sum_text,
                                        CT_SUM_RTAB_LENGTH * 2 + 1,
                                        CT_SUM_RTAB_LENGTH),
                                ' '),
                            CT_SUM_RTAB_LENGTH)),
                    '<SUM_TAB>',
                    PrintRight (
                        TRIM (TO_CHAR (l_sum_tab, '999999999990.00')),
                        15));
            v_text := SUBSTR (l_sum_text, v_index, 21);

            WHILE v_text IS NOT NULL
            LOOP
                l_buff :=
                       l_buff
                    || l_footer_tab_end
                    || v_text
                    || CHR (13)
                    || CHR (10);
                v_index := v_index + 21;
                v_text := SUBSTR (l_sum_text, v_index, 21);
            END LOOP;

            l_buff :=
                   l_buff
                || l_footer_tab_end
                || CHR (13)
                || CHR (10)
                || REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (l_footer_doc,
                                        '<ORG_HEAD>',
                                        PrintLeft (l_org_head, 30)),
                               '<USER_PIB>',
                               PrintLeft (''          /*tools.GetCurrUserPIB*/
                                            , 50)),
                           '<BUCH_PIB>',
                           PrintLeft (                              /*tools.*/
                                      get_acc_setup_pib (1, 1, l_com_org),
                                      50)),
                       '<ORG_BUH>',
                       PrintLeft (l_org_buh, 30));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT CASE
                   WHEN pr_tp = 'A'
                   THEN
                       SUBSTR (
                              ''                 --' КАТЕГОРІЯ ' || t.npt_code
                           || ' ПЕРІОД '
                           ||                                           -- l_per_num
                              (SELECT COUNT (1)
                                 FROM v_payroll p2
                                WHERE     p2.pr_month = pr.pr_month
                                      AND p2.com_org = pr.com_org
                                      AND p2.pr_npc = pr.pr_npc
                                      AND p2.pr_pay_tp = pr.pr_pay_tp
                                      ---and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                      AND p2.pr_create_dt <= pr.pr_create_dt)
                           || ' '
                           || c.npc_name,
                           1,
                           79)
                   ELSE
                       ''
               END,
                  ' ПЕРІОД '
               ||                                                     /*pr_per_num*/
                                                                        -- l_per_num
                  (SELECT COUNT (1)
                     FROM v_payroll p2
                    WHERE     p2.pr_month = pr.pr_month
                          AND p2.com_org = pr.com_org
                          AND p2.pr_npc = pr.pr_npc
                          AND p2.pr_pay_tp = pr.pr_pay_tp
                          --and p2.pr_tp = pr.pr_tp  --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                          AND p2.pr_create_dt <= pr.pr_create_dt),
               npc_name,
               npc_code,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,
               org_code                        --  #89720 Виправити назву УСЗН
                       ,
               (SELECT UPPER (z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn)
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'A'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS main_buch,
               (SELECT z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'B'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS head_department, --  #91566 to_char(r.Pr_Create_Dt, 'MM')||'-й місяць '||to_char(r.Pr_Create_Dt, 'YYYY') AS supl_month,
                  TO_CHAR (pr.Pr_month, 'MM')
               || '-й місяць '
               || TO_CHAR (pr.Pr_month, 'YYYY'),
               com_org
          INTO l_a_pr_name,
               l_a_per_num,
               l_npc_name,
               l_npc_code,
               l_org_name,
               l_org_code,
               l_org_buh,
               l_org_head,
               l_supl_month,
               l_com_org
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr.pr_npc
               JOIN v_opfu op ON org_id = com_org
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id;

        PageHeader;
        DBMS_OUTPUT.put_line (2222);
        TabHeader (p_ORG_NAME     => l_org_name,
                   p_ORG_CODE     => l_org_code,
                   p_SUPL_MONTH   => l_supl_month,
                   p_PAGE_NUM     => 1);

        FOR rr
            IN (SELECT ROW_NUMBER () OVER (ORDER BY pib)     AS num, --Порядковий номер
                       pib                                   AS pib, --Прізвище, ім’я та по батькові
                       pa_num                                AS acc_num, --Номер особового рахунка (пенсійного посвідчення)
                       tot_sum, ---to_char(tot_sum, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.''''') AS tot_sum, --Сума, що підлягає перерахуванню
                       address,
                       prs_fn                                AS PP_ORG_NAME,
                       prs_account                           AS IBAN,
                       nb_name                               AS BANK_NAME,
                       nb_mfo                                AS BANK_MFO,
                       nb_edrpou                             AS BANK_CODE
                  FROM (  SELECT       --row_number() OVER (order BY 1) as c1,
                                 a.pa_num,
                                 uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                                     AS pib,
                                 uss_person.api$sc_tools.get_address (pc.pc_sc,
                                                                      3)
                                     AS address,
                                 SUM (d.prsd_sum)
                                     AS tot_sum,
                                 t.prs_fn,
                                 t.prs_account,
                                 nb_name,
                                 nb_mfo,
                                 DPP_TAX_CODE
                                     AS nb_edrpou -- #91566 nb_edrpou -- ЄДРПОУ НЕ виплатної організації А !!! отримувача
                            FROM uss_esr.v_pr_sheet t
                                 JOIN uss_esr.v_pr_sheet_detail d
                                     ON (    d.prsd_prs_dn = t.prs_id
                                         AND d.prsd_pr = t.prs_pr
                                         AND d.prsd_prs_dn IS NOT NULL)
                                 JOIN uss_esr.v_personalcase pc
                                     ON (pc.pc_id = d.prsd_pc)
                                 JOIN uss_esr.v_pc_account a
                                     ON (a.pa_id = d.prsd_pa)
                                 LEFT JOIN uss_ndi.v_ndi_pay_person pp
                                     ON pp.dpp_id = t.prs_dpp
                                 LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                                     ON (    ppa.dppa_dpp = t.prs_dpp
                                         AND ppa.history_status = 'A'
                                         AND ppa.dppa_is_main = 1)
                                 LEFT JOIN uss_ndi.v_ndi_bank b
                                     ON (b.nb_id =
                                         COALESCE (ppa.dppa_nb, t.prs_nb))
                           WHERE t.prs_pr = p_pr_id AND t.prs_tp = p_prs_tp
                        GROUP BY a.pa_num,
                                 pc_sc,
                                 t.prs_fn,
                                 t.prs_nb,
                                 t.prs_dpp,
                                 t.prs_account,
                                 nb_name,
                                 nb_mfo,
                                 DPP_TAX_CODE                    /*nb_edrpou*/
                                             ))
        LOOP
            IF l_row_num >= l_page_height
            THEN
                PageHeader;
                TabHeader (p_ORG_NAME     => l_org_name,
                           p_ORG_CODE     => l_org_code,
                           p_SUPL_MONTH   => l_supl_month,
                           p_PAGE_NUM     => l_page_num);
                l_row_num := 0;
            END IF;

            TabBody (p_NUM           => rr.num,
                     p_PC_NUM        => rr.acc_num,
                     p_pp_sum        => rr.tot_sum,
                     p_pib           => rr.pib,
                     p_address       => rr.address,
                     p_PP_ORG_NAME   => rr.PP_ORG_NAME,
                     p_IBAN          => rr.IBAN,
                     p_BANK_NAME     => rr.BANK_NAME,
                     p_BANK_MFO      => rr.BANK_MFO,
                     p_BANK_CODE     => rr.BANK_CODE);
        END LOOP;

        TabFooter;
        --
        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "РЕЄСТР вiдрахувань з допомог "');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "РЕЄСТР вiдрахувань з допомог ": '
                || ', n='
                || TO_CHAR (n)
                || ' '
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildDeduction_R1;

    -- СУПРОВIДНА ВIДОМIСТЬ
    PROCEDURE BuildSuprovid_R1 (
        p_pr_id    IN            payroll.pr_id%TYPE,
        p_prs_tp   IN            pr_sheet.prs_tp%TYPE DEFAULT 'ABP',
        p_rpt      IN OUT NOCOPY BLOB)
    IS
        p_asopd                  VARCHAR2 (10) := '';
        ---l_org_id     payroll.com_org%type;
        l_buff                   VARCHAR2 (32767);
        l_buff2                  VARCHAR2 (32767);
        l_pr_start_dt            payroll.pr_start_dt%TYPE;
        l_org_name               v_opfu.org_name%TYPE;
        l_org_code               v_opfu.org_code%TYPE;
        l_per_year               NUMBER (4);      ---nsi_period.per_year%type;
        l_per_month              NUMBER (2);     ---nsi_period.per_month%type;
        l_date_start             VARCHAR2 (10);
        l_date_stop              VARCHAR2 (10);
        l_per_num                NUMBER (14) := 1; --  Виплатний період ?????  payroll.pr_per_num%type;
        l_ved_tp                 CHAR (20);
        l_prs_num                pr_sheet.prs_num%TYPE DEFAULT 0;
        l_org_id                 v_opfu.ORG_ID%TYPE DEFAULT 0;
        l_prs_index              uss_ndi.v_ndi_post_office.npo_index%TYPE DEFAULT NULL;
        l_rn_rep                 PLS_INTEGER DEFAULT 0;
        l_sum_tab                NUMBER;
        l_sum_text               VARCHAR2 (512);
        n                        NUMBER := 1;
        v_address_1              VARCHAR2 (100);
        v_address_2              VARCHAR2 (100);
        v_address_3              VARCHAR2 (100);
        v_address_4              VARCHAR2 (100);
        l_org_head               VARCHAR2 (40);
        l_org_buh                VARCHAR2 (40);
        l_supl_month             VARCHAR2 (40);
        v_count                  NUMBER;
        v_instr                  NUMBER;
        l_a_pr_name              VARCHAR2 (100);
        l_a_per_num              VARCHAR2 (20) := 1; --  Виплатний період ?????
        l_npc_name               VARCHAR2 (100);
        l_npc_code               VARCHAR2 (100);
        l_SUM_ALL                NUMBER;
        l_CNT_ALL                NUMBER;
        l_PAGE_ALL               NUMBER;
        --l_page_width number := 134;
        --
        Ct_pnf_pib_LENGTH        INTEGER := 22;
        CT_ADDRESS_LENGTH        INTEGER := 25;
        CT_ORGNAME_LENGTH        INTEGER := 20;
        CT_PASSPORT_LENGTH       INTEGER := 15                          /*10*/
                                              ;       --  різні довідки і т.д.
        CT_OPFU_LENGTH           INTEGER := 75;
        CT_CNTR_LENGTH           INTEGER := 28;
        CT_SUM_TEXT_TAB_LENGTH   INTEGER := 103;
        CT_SUM_RTAB_LENGTH       INTEGER := 26;
        --
        l_page_header            VARCHAR2 (32767)
            :=    ' '
               || CHR (13)
               || CHR (10)
               ||                          --#accomp_desc_num#  #supl_desc_dt#
                  '                          СУПРОВIДНА ВIДОМIСТЬ'
               || CHR (13)
               || CHR (10)
               || ''
               || CHR (13)
               || CHR (10)
               || '       спискiв на вiдрахування з допомог на користь юридичних осiб'
               || CHR (13)
               || CHR (10)
               || '                       за  <SUPL_MONTH> р.'
               || CHR (13)
               || CHR (10)
               || '  <ORG_NAME>'
               || CHR (13)
               || CHR (10)
               || '                                                      Аркуш <PAGE_NUM>'
               || CHR (13)
               || CHR (10)
               || '  +----+------+--------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦                    ¦          ¦           ¦          ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ No ¦  No  ¦  Назва органiзацiї ¦  Сума,   ¦ Кiлькiсть,¦Кiлькiсть ¦'
               || CHR (13)
               || CHR (10)
               || '  ¦ п/п¦списку¦                    ¦ грн.коп. ¦   чол.    ¦ аркушiв  ¦'
               || CHR (13)
               || CHR (10)
               || '  +----+------+--------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1 ¦  2   ¦         3          ¦    4     ¦     5     ¦     6    ¦'
               || CHR (13)
               || CHR (10);

        l_tab_header             VARCHAR2 (32767)
            :=    '                                                      Аркуш <PAGE_NUM> '
               || CHR (13)
               || CHR (10)
               || '  +----+------+--------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦  1 ¦  2   ¦         3          ¦    4     ¦     5     ¦     6    ¦'
               || CHR (13)
               || CHR (10);

        l_body_tab               VARCHAR2 (32767)
            :=    '  +----+------+--------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦<NN>¦<PRS_NUM>¦<PP_ORG_NAME1>¦<PP_SUM>¦<PP_CNT>¦<PAGE_CNT>¦'
               || CHR (13)
               || CHR (10)
               || '  ¦    ¦      ¦<PP_ORG_NAME2>¦          ¦           ¦          ¦'
               || CHR (13)
               || CHR (10);

        l_body_line3             VARCHAR2 (1000)
            :=    '  ¦    ¦      ¦<PP_ORG_NAME3>¦          ¦           ¦          ¦'
               || CHR (13)
               || CHR (10);

        l_footer_tab             VARCHAR2 (32767)
            :=    '  +----+------+--------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10)
               || '  ¦     Всього                     ¦<SUM_ALL>¦<CNT_ALL>¦<PAGE_ALL>¦'
               || CHR (13)
               || CHR (10)
               || '  +--------------------------------+----------+-----------+----------+'
               || CHR (13)
               || CHR (10);
        l_footer_tab_end         VARCHAR2 (32767) := '';
        l_footer_doc             VARCHAR2 (32767)
            :=    -- '' || chr(13) || chr(10) ||
                  '      Вiдповiдальна особа __________________'
               || CHR (13)
               || CHR (10)
               || '                           (пiдпис)'
               || CHR (13)
               || CHR (10);

        l_page_num               NUMBER := 0;
        l_row_num                NUMBER := 0;              -- лічильник блоків
        l_page_height            NUMBER := 20;      -- к-ть блоків на сторінку
        l_rep                    t_b1m_table;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_buff2 :=
                   '
 -------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);
            l_buff :=
                   CHR (12)
                || ' -------------------------------------------------------------------------------------------------------------------------------'
                || CHR (13)
                || CHR (10);

            IF l_row_num <= 1
            THEN
                l_buff := REPLACE (REPLACE (l_buff, CHR (12), ''), '
', '');
            END IF;

            l_page_num := l_page_num + 1;
            l_row_num := 0;

            IF l_page_num > 1
            THEN
                DBMS_LOB.writeappend (
                    p_rpt,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                    UTL_RAW.cast_to_raw (l_buff));
            END IF;
        END;

        --
        PROCEDURE TabHeader (p_ORG_NAME     IN VARCHAR2,
                             p_ORG_CODE     IN VARCHAR2,
                             p_SUPL_MONTH   IN VARCHAR2,
                             p_PAGE_NUM     IN INTEGER)
        IS
        BEGIN
            IF p_PAGE_NUM = 1
            THEN
                l_buff := l_page_header;
            ELSE
                l_buff := l_tab_header;
            END IF;

            --l_buff := REPLACE(l_buff, '<ORG_CODE>', PrintLeft(trim(substr(p_ORG_CODE, 1, 5 )) ,5));
            l_buff :=
                REPLACE (
                    l_buff,
                    '<ORG_NAME>',
                    PrintCenter (
                        TRIM (
                            SUBSTR (p_ORG_CODE || ' ' || p_ORG_NAME, 1, 68)),
                        68));                                               --
            l_buff :=
                REPLACE (l_buff,
                         '<ACCOMP_DESC_NUM>',
                         PrintLeft (p_pr_id, 15));
            l_buff :=
                REPLACE (l_buff,
                         '<SUPL_MONTH>',
                         PrintLeft (p_SUPL_MONTH, 16));
            l_buff :=
                REPLACE (l_buff, '<PAGE_NUM>', PrintRight (p_PAGE_NUM, 4));

            l_rn_rep := 0;
            l_sum_tab := 0;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
            l_row_num := 0;                                 -- l_row_num + 20;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'TabHeader: '
                    || ', n='
                    || TO_CHAR (n)
                    || ' '
                    || CHR (13)
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END;

        --
        PROCEDURE TabBody (p_NUM           IN VARCHAR2,
                           p_PRS_NUM       IN VARCHAR2,
                           p_PP_ORG_NAME   IN VARCHAR2,
                           p_pp_sum        IN NUMBER,
                           p_PP_CNT        IN NUMBER,
                           p_PAGE_CNT      IN NUMBER)
        IS
            v_sum     VARCHAR2 (30)
                          := TRIM (TO_CHAR (ROUND (p_pp_sum, 2), '9999990.00'));
            l_name1   VARCHAR2 (255);
            l_name2   VARCHAR2 (255);
            l_name3   VARCHAR2 (255);
            l_name4   VARCHAR2 (255);
            l_buff0   VARCHAR2 (32000);
        BEGIN
            l_rn_rep := l_rn_rep + 1;

            l_name1 :=
                PrintLeft (
                    COALESCE (SUBSTR (p_PP_ORG_NAME, 1, CT_ORGNAME_LENGTH),
                              ' '),
                    CT_ORGNAME_LENGTH);
            l_name2 :=
                PrintLeft (
                    COALESCE (
                        SUBSTR (p_PP_ORG_NAME,
                                CT_ORGNAME_LENGTH + 1,
                                CT_ORGNAME_LENGTH),
                        ' '),
                    CT_ORGNAME_LENGTH);
            l_name3 := SUBSTR (p_PP_ORG_NAME, 2 * CT_ORGNAME_LENGTH + 1);
            /*     l_name3 := PrintLeft(coalesce(substr(p_PP_ORG_NAME, 2*CT_ORGNAME_LENGTH+1, CT_ORGNAME_LENGTH), ' '),CT_ORGNAME_LENGTH);
               if l_name3 is not null then
                  l_buff0 := replace(l_body_line3, '<PP_ORG_NAME3>', PrintLeft(coalesce(l_name3,' '),CT_ORGNAME_LENGTH) );
                else
                  l_buff0 := '';
                end if;*/

            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (l_body_tab,
                                                 '<NN>',
                                                 PrintRight (p_num, 4)),
                                        '<PRS_NUM>',
                                        PrintLeft (TO_CHAR (p_PRS_NUM), 6)),
                                    '<PP_ORG_NAME1>',
                                    PrintLeft (COALESCE (l_name1, ' '),
                                               CT_ORGNAME_LENGTH)),
                                '<PP_ORG_NAME2>',
                                PrintLeft (COALESCE (l_name2, ' '),
                                           CT_ORGNAME_LENGTH)),
                            '<PP_SUM>',
                            PrintRight (v_sum, 10)),
                        '<PP_CNT>',
                        PrintRight (TO_CHAR (p_PP_CNT), 11)),
                    '<PAGE_CNT>',
                    PrintRight (TO_CHAR (p_PAGE_CNT), 10))--|| l_buff0
                                                          ;

            IF l_name3 IS NOT NULL
            THEN
                DECLARE
                    l_index3      INTEGER := /*CT_ADDRESS_LENGTH + CT_ADDRESS_LENGTH*/
                                             +1;
                    l_len3        INTEGER := CT_ORGNAME_LENGTH;
                    l_max_line3   INTEGER := 3;
                    i3            INTEGER := 0;
                    l_str3        VARCHAR2 (255) := l_name3; -- substr(p_address, l_index3, l_len3);
                    l_buff3       VARCHAR2 (5000);
                BEGIN
                    WHILE l_str3 IS NOT NULL AND i3 < l_max_line3
                    LOOP
                        l_buff3 :=
                            REPLACE (
                                l_body_line3,
                                '<PP_ORG_NAME3>',
                                PrintLeft (COALESCE (l_str3, ' '), l_len3));
                        l_index3 := l_index3 + l_len3;
                        l_str3 := SUBSTR (l_name3, l_index3, l_len3);
                        l_buff := l_buff || l_buff3;
                        i3 := i3 + 1;
                    END LOOP;
                END;
            END IF;

            l_row_num := l_row_num + 1;
            l_sum_tab := l_sum_tab + ROUND (p_pp_sum, 2);
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE TabFooter
        IS
            v_index   PLS_INTEGER DEFAULT 64;
            v_text    VARCHAR2 (21);
        BEGIN
            l_buff :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            l_footer_tab,
                            '<SUM_ALL>',
                            PrintRight (
                                TRIM (
                                    TO_CHAR (ROUND (l_SUM_ALL, 2),
                                             '9999990.00')),
                                10)),
                        '<CNT_ALL>',
                        PrintRight (TO_CHAR (l_CNT_ALL), 11)),
                    '<PAGE_ALL>',
                    PrintRight (TO_CHAR (l_PAGE_ALL), 10));
            /*      v_text:=substr(l_sum_text,v_index,21);
                  while v_text is not null
                    loop
                      l_buff:=l_buff||l_footer_tab_end||v_text||chr(13)||chr(10);
                      v_index:=v_index+21;
                      v_text:=substr(l_sum_text,v_index,21);
                    end loop;*/
            l_buff :=
                   l_buff
                || l_footer_tab_end
                || CHR (13)
                || CHR (10)
                || REPLACE (
                       REPLACE (l_footer_doc,
                                '<ORG_HEAD>',
                                PrintLeft (l_org_head, 30)),
                       '<ORG_BUH>',
                       PrintLeft (l_org_buh, 30));
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;
    BEGIN
        SELECT CASE
                   WHEN pr_tp = 'A'
                   THEN
                       SUBSTR (
                              ''                 --' КАТЕГОРІЯ ' || t.npt_code
                           || ' ПЕРІОД '
                           ||                                           -- l_per_num
                              (SELECT COUNT (1)
                                 FROM v_payroll p2
                                WHERE     p2.pr_month = pr.pr_month
                                      AND p2.com_org = pr.com_org
                                      AND p2.pr_npc = pr.pr_npc
                                      AND p2.pr_pay_tp = pr.pr_pay_tp
                                      ---and p2.pr_tp = pr.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                      AND p2.pr_create_dt <= pr.pr_create_dt)
                           || ' '
                           || c.npc_name,
                           1,
                           79)
                   ELSE
                       ''
               END,
                  ' ПЕРІОД '
               ||                                                     /*pr_per_num*/
                                                                        -- l_per_num
                  (SELECT COUNT (1)
                     FROM v_payroll p2
                    WHERE     p2.pr_month = pr.pr_month
                          AND p2.com_org = pr.com_org
                          AND p2.pr_npc = pr.pr_npc
                          AND p2.pr_pay_tp = pr.pr_pay_tp
                          --and p2.pr_tp = pr.pr_tp  --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                          AND p2.pr_create_dt <= pr.pr_create_dt),
               npc_name,
               npc_code,
               UPPER (NVL (dpp.dpp_sname, get_org_sname (org_name)))
                   opfu_name,
               org_code                        --  #89720 Виправити назву УСЗН
                       ,
               (SELECT UPPER (z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn)
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'A'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS main_buch,
               (SELECT z.fnc_ln || ' ' || z.fnc_fn || ' ' || z.fnc_mn
                  FROM uss_ndi.v_ndi_functionary z
                 WHERE     z.fnc_tp = 'B'
                       AND z.history_status = 'A'
                       AND z.com_org = pr.com_org
                 FETCH FIRST ROW ONLY)
                   AS head_department, --  #91566to_char(pr.Pr_Create_Dt, 'MM')||'-й місяць '||to_char(pr.Pr_Create_Dt, 'YYYY')
                  TO_CHAR (pr.Pr_month, 'MM')
               || '-й місяць '
               || TO_CHAR (pr.Pr_month, 'YYYY')
          INTO l_a_pr_name,
               l_a_per_num,
               l_npc_name,
               l_npc_code,
               l_org_name,
               l_org_code,
               l_org_buh,
               l_org_head,
               l_supl_month
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = pr.pr_npc
               JOIN v_opfu op ON org_id = com_org
               LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                   ON     dpp.dpp_org = op.org_id
                      AND dpp.dpp_tp = 'OSZN'
                      AND dpp.history_status = 'A'                  --  #89720
         WHERE pr_id = p_pr_id;

        SELECT SUM (PP_SUM), SUM (PP_CNT), SUM (PAGE_CNT)
          INTO l_SUM_ALL, l_CNT_ALL, l_PAGE_ALL
          FROM (  SELECT ROW_NUMBER () OVER (ORDER BY 1)    AS num,
                         t.prs_num                          AS PRS_NUM,
                         t.prs_fn                           AS PP_ORG_NAME,
                         SUM (d.prsd_sum)                   AS PP_SUM,
                         COUNT (DISTINCT d.prsd_pc)         AS PP_CNT,
                           GREATEST (
                               0,
                               CEIL (
                                     (COUNT (DISTINCT d.prsd_pc) - 5)
                                   / DECODE (p_prs_tp,
                                             'ABU', 15,
                                             'AUU', 25,
                                             20)))
                         + 1                                AS PAGE_CNT
                    FROM uss_esr.v_pr_sheet t
                         JOIN uss_esr.v_pr_sheet_detail d
                             ON (    d.prsd_prs_dn = t.prs_id
                                 AND d.prsd_pr = t.prs_pr
                                 AND d.prsd_prs_dn IS NOT NULL)
                         JOIN uss_esr.v_personalcase pc
                             ON (pc.pc_id = d.prsd_pc)
                   WHERE t.prs_pr = p_pr_id AND t.prs_tp = p_prs_tp
                GROUP BY prs_num, t.prs_fn, t.prs_id);

        PageHeader;
        DBMS_OUTPUT.put_line (2222);
        TabHeader (p_ORG_NAME     => l_org_name,
                   p_ORG_CODE     => l_org_code,
                   p_SUPL_MONTH   => l_supl_month,
                   p_PAGE_NUM     => 1);

        FOR rr
            IN (SELECT num,
                       PRS_NUM,
                       PP_ORG_NAME,
                       PP_SUM,
                       PP_CNT,
                       PAGE_CNT
                  FROM (  SELECT ROW_NUMBER () OVER (ORDER BY 1)
                                     AS num,
                                 t.prs_num
                                     AS PRS_NUM,
                                 t.prs_fn /*||' hsdfhsdfh eehesfh hgesrfhg9'*/
                                     AS PP_ORG_NAME,
                                 SUM (d.prsd_sum)
                                     AS PP_SUM,
                                 COUNT (DISTINCT d.prsd_pc)
                                     AS PP_CNT,
                                   GREATEST (
                                       0,
                                       CEIL (
                                             (COUNT (DISTINCT d.prsd_pc) - 5)
                                           / DECODE (p_prs_tp,
                                                     'ABU', 15,
                                                     'AUU', 25,
                                                     20)))
                                 + 1
                                     AS PAGE_CNT
                            FROM uss_esr.v_pr_sheet t
                                 JOIN uss_esr.v_pr_sheet_detail d
                                     ON (    d.prsd_prs_dn = t.prs_id
                                         AND d.prsd_pr = t.prs_pr
                                         AND d.prsd_prs_dn IS NOT NULL)
                                 JOIN uss_esr.v_personalcase pc
                                     ON (pc.pc_id = d.prsd_pc)
                           WHERE t.prs_pr = p_pr_id AND t.prs_tp = p_prs_tp
                        GROUP BY prs_num, t.prs_fn, t.prs_id))
        LOOP
            IF l_row_num >= l_page_height
            THEN
                PageHeader;
                TabHeader (p_ORG_NAME     => l_org_name,
                           p_ORG_CODE     => l_org_code,
                           p_SUPL_MONTH   => l_supl_month,
                           p_PAGE_NUM     => l_page_num);
                l_row_num := 0;
            END IF;

            TabBody (p_NUM           => rr.num,
                     p_PRS_NUM       => rr.PRS_NUM,
                     p_PP_ORG_NAME   => rr.PP_ORG_NAME,
                     p_PP_SUM        => rr.PP_SUM,
                     p_PP_CNT        => rr.PP_CNT,
                     p_PAGE_CNT      => rr.PAGE_CNT);
        END LOOP;

        TabFooter;
        --
        p_rpt :=
            tools.ConvertC2B (
                CONVERT (ReplUKRSmb2DosBank (tools.ConvertB2C (p_rpt), 'K'),
                         'RU8PC866',
                         'CL8MSWIN1251'));                          --  #86973
        add_CT_ASCII_FF (p_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація в відомості: "СУПРОВIДНА ВIДОМIСТЬ"');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "СУПРОВIДНА ВIДОМIСТЬ": '
                || ', n='
                || TO_CHAR (n)
                || ' '
                || CHR (13)
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildSuprovid_r1;

    -- Формуємо архів з файлами друкованих форм по відрахуваннях/утриманнях
    -- p_prs_tp = 'ABU' /  'AUU'  ----  Відрахування банком (ю.особа) /  Утримання (ю.особа)
    PROCEDURE BuildAccrualFile (p_pr_list    IN            VARCHAR2,
                                p_prs_tp     IN            VARCHAR2,
                                p_rpt        IN OUT NOCOPY BLOB,
                                p_rpt_name      OUT        VARCHAR2)
    IS
        l_files      ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
    BEGIN
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT || '.BuildAccrualFile',
            action_name   =>
                'p_prs_tp=' || p_prs_tp || ';' || 'p_pr_id=' || p_pr_list);

        l_pr_files := ikis_sysweb.tbl_some_files ();

        FOR pp
            IN (SELECT pr.pr_id, pr.com_org
                  FROM payroll  pr
                       JOIN
                       (    SELECT REGEXP_SUBSTR (text,
                                                  '[^(\,)]+',
                                                  1,
                                                  LEVEL)    AS z_pr_id
                              FROM (SELECT p_pr_list AS text FROM DUAL)
                        CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)) > 0) z
                           ON z.z_pr_id = pr.pr_id
                 WHERE     1 = 1                      -- pr.pr_pay_tp = 'POST'
                       AND EXISTS
                               (SELECT 1
                                  FROM pr_sheet s
                                 WHERE     prs_pr = pr_id
                                       AND prs_tp = p_prs_tp
                                       AND prs_st != 'PP'))
        LOOP
            l_files := ikis_sysweb.tbl_some_files ();

            IF p_prs_tp = 'ABU'
            THEN                             --  Відрахування банком (ю.особа)
                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildAccrualList_R2 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_01.txt', p_rpt);
                END IF;

                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildDeduction_R1 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_02.txt', p_rpt);
                END IF;

                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildSuprovid_R1 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_03.txt', p_rpt);
                END IF;
            ELSIF p_prs_tp = 'AUU'
            THEN                                        -- Утримання (ю.особа)
                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildAccrualList_R1 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_04.txt', p_rpt);
                END IF;

                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildDeduction_R1 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_05.txt', p_rpt);
                END IF;

                DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
                DBMS_LOB.open (lob_loc     => p_rpt,
                               open_mode   => DBMS_LOB.lob_readwrite);

                BuildSuprovid_R1 (pp.pr_id, p_prs_tp, p_rpt);

                IF p_rpt IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info ('rpt_06.txt', p_rpt);
                END IF;
            END IF;

            IF l_files.COUNT > 0
            THEN
                l_pr_files.EXTEND;
                p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        'pr_' || pp.com_org || '_' || pp.pr_id || '.zip',
                        p_rpt);
            ELSE
                p_rpt := NULL;
            END IF;
        END LOOP;

        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
            p_rpt_name :=
                'rpt_acc_' || TO_CHAR (SYSDATE, 'yyyymmddhh24miss') || '.zip';
        ELSE
            p_rpt := NULL;
            p_rpt_name := '';
            RAISE exNoData;
        END IF;
    EXCEPTION
        WHEN exNoData
        THEN
            --raise_application_error(-20000,'Відсутня інформація для побудови файлу друкованих форм по відрахуваннях');
            raise_application_error (
                -20000,
                'Відсутня інформація для побудови звіту!');
        WHEN OTHERS
        THEN
            IF SQLCODE = -20001 OR SQLCODE = -20000
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'BuildPostFile: '
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
            END IF;
    END BuildAccrualFile;
BEGIN
    NULL;
END DNET$RPT_MATRIX;
/