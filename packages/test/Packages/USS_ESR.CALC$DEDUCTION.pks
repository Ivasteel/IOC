/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CALC$DEDUCTION
IS
    -- Author  : VANO
    -- Created : 09.12.2021 18:13:42
    -- Purpose : Функції розрахунку сум відрахувань для розрахунку рішення тощо

    PROCEDURE calc_deductions_for_pd;
END CALC$DEDUCTION;
/


/* Formatted on 8/12/2025 5:49:17 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CALC$DEDUCTION
IS
    PROCEDURE SaveMessage (p_message IN VARCHAR2)
    AS
    BEGIN
        API$PC_DECISION.SaveMessage (p_message);
    END;

    PROCEDURE calc_deductions_for_pd
    IS
    /*BEGIN
      NULL;
    END;

    PROCEDURE calc_deductions_for_pd_main
    IS*/
    BEGIN
        RETURN;
        SaveMessage ('Розраховуємо суми відрахувань');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            WITH
                income
                AS
                    (  SELECT tdc_npt             AS z_npt,
                              tdc_pd              AS z_pd,
                              tdc_key             AS z_pdf,
                              tdc_start_dt        AS z_start_dt,
                              SUM (tdc_value)     AS z_sum
                         FROM tmp_pd_detail_calc
                        WHERE tdc_npt IS NOT NULL
                     GROUP BY tdc_npt,
                              tdc_key,
                              tdc_pd,
                              tdc_start_dt)
            SELECT 400,
                   400,
                   td_pdf,
                   td_pd,
                   td_begin,
                   td_end,
                      'Сума відрахування на користь "'
                   || (SELECT dpp_name
                         FROM uss_ndi.v_ndi_pay_person
                        WHERE dn_dpp = dpp_id)
                   || '"',
                   CASE dnd_tp
                       WHEN 'PD'
                       THEN
                           ROUND (z_sum * dnd_value / 100, 2)
                       WHEN 'AS'
                       THEN
                           dnd_value
                       WHEN 'SD'
                       THEN
                           ROUND (z_sum * dnd_value / dnd_value_prefix, 2)
                       WHEN 'PL'
                       THEN
                           ROUND (
                               (SELECT lgw_cmn_sum * dnd_value / 100
                                  FROM uss_ndi.v_ndi_living_wage lgw
                                 WHERE     lgw.history_status = 'A'
                                       AND td_begin >= lgw_start_dt
                                       AND (   td_begin <= lgw_stop_dt
                                            OR lgw_stop_dt IS NULL)),
                               2)
                       ELSE
                           0
                   END    AS k_sum,
                   z_npt
              FROM tmp_tar_dates,
                   tmp_pd_calc_params,
                   tmp_pdf_calc_params,
                   deduction,
                   dn_detail  dd,
                   uss_ndi.v_ndi_nst_dn_config,
                   pc_state_alimony,
                   income
             WHERE     td_pd = xpd_id
                   AND xpd_pc = dn_pc
                   AND dnd_dn = dn_id
                   AND dd.history_status = 'A'
                   AND xpd_nst = nnnc_nst
                   AND dn_ndn = nnnc_ndn
                   AND td_begin >= dnd_start_dt
                   AND (td_begin <= dnd_stop_dt OR dnd_stop_dt IS NULL)
                   AND dnd_tp IS NOT NULL
                   AND td_pd = xpdf_pd
                   AND (td_pdf = xpdf_id OR td_pdf IS NULL)
                   AND dn_ps = ps_id(+)
                   AND (dn_ps IS NULL OR ps_sc = xpdf_sc)
                   AND z_pd = td_pd
                   AND z_start_dt = td_begin
                   AND (z_pdf = td_pdf OR td_pdf IS NULL);

        SaveMessage ('Розраховуємо суми що залишаються отримувачу');

        INSERT INTO tmp_pd_detail_calc (tdc_ndp,
                                        tdc_row_order,
                                        tdc_key,
                                        tdc_pd,
                                        tdc_start_dt,
                                        tdc_stop_dt,
                                        tdc_row_name,
                                        tdc_value,
                                        tdc_npt)
            WITH
                income
                AS
                    (  SELECT tdc_npt             AS z_npt,
                              tdc_pd              AS z_pd,
                              tdc_key             AS z_key,
                              tdc_start_dt        AS z_start_dt,
                              tdc_stop_dt         AS z_stop_dt,
                              SUM (tdc_value)     AS z_sum
                         FROM tmp_pd_detail_calc
                        WHERE tdc_npt IS NOT NULL AND tdc_ndp <> 400
                     GROUP BY tdc_npt,
                              tdc_pd,
                              tdc_start_dt,
                              tdc_stop_dt,
                              tdc_key),
                deduct
                AS
                    (  SELECT tdc_npt             AS x_npt,
                              tdc_pd              AS x_pd,
                              tdc_key             AS x_key,
                              tdc_start_dt        AS x_start_dt,
                              SUM (tdc_value)     AS x_sum
                         FROM tmp_pd_detail_calc
                        WHERE tdc_ndp = 400
                     GROUP BY tdc_npt,
                              tdc_pd,
                              tdc_start_dt,
                              tdc_key)
            SELECT 401,
                   401,
                   z_key,
                   z_pd,
                   z_start_dt,
                   z_stop_dt,
                   'Сума на користь отримувача',
                   z_sum - NVL (x_sum, 0),
                   x_npt
              FROM income, deduct
             WHERE     x_pd = z_pd
                   AND x_key = z_key
                   AND x_start_dt = z_start_dt
                   AND x_npt = z_npt;
    END;
BEGIN
    -- Initialization
    NULL;
END CALC$DEDUCTION;
/