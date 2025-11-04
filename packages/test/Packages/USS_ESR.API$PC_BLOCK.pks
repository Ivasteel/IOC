/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_BLOCK
IS
    -- Author  : LESHA
    -- Created : 12.09.2022 12:26:53
    -- Purpose :
    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE CLEAR_BLOCK;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE decision_block (p_hs NUMBER);

    PROCEDURE decision_block_pp (p_hs NUMBER);
END API$PC_BLOCK;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_BLOCK
IS
    --===========================================================================--
    g_check_1101   BOOLEAN;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE CLEAR_BLOCK
    IS
    BEGIN
        DELETE FROM tmp_pc_block
              WHERE 1 = 1;

        g_check_1101 := TRUE;
    END;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE accrual_period_block (p_hs_id histsession.hs_id%TYPE)
    IS
        accrual_period   pd_accrual_period%ROWTYPE;
    BEGIN
        FOR b IN (SELECT *
                    FROM tmp_pc_block
                   WHERE b_tp IN ('APR',
                                  'PPR',
                                  'HPR',
                                  'RPP'))
        LOOP
            accrual_period := NULL;

            FOR per
                IN (  SELECT ac.*
                        FROM pd_accrual_period ac
                       WHERE     b.b_pd = ac.pdap_pd
                             AND ac.history_status = 'A'
                             AND b.b_dt BETWEEN ac.pdap_start_dt
                                            AND ac.pdap_stop_dt
                    ORDER BY ac.pdap_id)
            LOOP
                accrual_period := per;

                UPDATE pd_accrual_period
                   SET history_status = 'H', pdap_hs_del = b.b_hs_lock
                 WHERE pdap_id = per.pdap_id;
            END LOOP;

            UPDATE pd_accrual_period ac
               SET history_status = 'H', pdap_hs_del = b.b_hs_lock
             WHERE     ac.pdap_pd = b.b_pd
                   AND ac.pdap_start_dt > b.b_dt
                   AND ac.history_status = 'A';

            IF accrual_period.pdap_id IS NOT NULL
            THEN
                accrual_period.pdap_id := 0;
                accrual_period.pdap_stop_dt := LAST_DAY (b.b_dt);
                accrual_period.pdap_hs_ins := b.b_hs_lock;
                accrual_period.pdap_hs_del := NULL;

                INSERT INTO pd_accrual_period
                     VALUES accrual_period;
            END IF;
        END LOOP;

        FOR b IN (SELECT *
                    FROM tmp_pc_block
                   WHERE b_tp IN ('HPD', 'PAP') AND b_stop_dt IS NOT NULL)
        LOOP
            accrual_period := NULL;

            FOR per
                IN (  SELECT ac.*
                        FROM pd_accrual_period ac
                       WHERE     b.b_pd = ac.pdap_pd
                             AND ac.history_status = 'A'
                             AND b.b_stop_dt BETWEEN ac.pdap_start_dt
                                                 AND ac.pdap_stop_dt
                    ORDER BY ac.pdap_id)
            LOOP
                accrual_period := per;

                IF per.pdap_stop_dt != b.b_stop_dt
                THEN
                    UPDATE pd_accrual_period
                       SET history_status = 'H', pdap_hs_del = b.b_hs_lock
                     WHERE pdap_id = per.pdap_id;
                END IF;
            END LOOP;

            UPDATE pd_accrual_period ac
               SET history_status = 'H', pdap_hs_del = b.b_hs_lock
             WHERE     ac.pdap_pd = b.b_pd
                   AND ac.pdap_start_dt > b.b_stop_dt
                   AND ac.history_status = 'A';

            IF accrual_period.pdap_stop_dt != b.b_stop_dt
            THEN
                accrual_period.pdap_id := 0;
                accrual_period.pdap_stop_dt := b.b_stop_dt;
                accrual_period.pdap_hs_ins := b.b_hs_lock;
                accrual_period.pdap_hs_del := NULL;

                INSERT INTO pd_accrual_period
                     VALUES accrual_period;
            END IF;
        END LOOP;

        FOR b IN (SELECT *
                    FROM tmp_pc_block
                   WHERE b_tp IN ('MR'))
        LOOP
            accrual_period := NULL;

            FOR per
                IN (  SELECT ac.*
                        FROM pd_accrual_period ac
                       WHERE     b.b_pd = ac.pdap_pd
                             AND ac.history_status = 'A'
                             AND b.b_dt BETWEEN ac.pdap_start_dt
                                            AND ac.pdap_stop_dt
                    ORDER BY ac.pdap_id)
            LOOP
                accrual_period := per;

                IF per.pdap_stop_dt != LAST_DAY (b.b_dt)
                THEN
                    UPDATE pd_accrual_period
                       SET history_status = 'H', pdap_hs_del = b.b_hs_lock
                     WHERE pdap_id = per.pdap_id;
                END IF;
            END LOOP;

            UPDATE pd_accrual_period ac
               SET history_status = 'H', pdap_hs_del = b.b_hs_lock
             WHERE     ac.pdap_pd = b.b_pd
                   AND ac.pdap_start_dt > b.b_dt
                   AND ac.history_status = 'A';

            IF      /*accrual_period.pdap_start_dt != trunc(b.b_dt,'MM') AND*/
               accrual_period.pdap_stop_dt != LAST_DAY (b.b_dt)
            THEN
                accrual_period.pdap_id := 0;
                accrual_period.pdap_stop_dt := LAST_DAY (b.b_dt);
                accrual_period.pdap_hs_ins := b.b_hs_lock;
                accrual_period.pdap_hs_del := NULL;

                INSERT INTO pd_accrual_period
                     VALUES accrual_period;
            END IF;
        END LOOP;
    END;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE decision_block (p_hs NUMBER)
    IS
        l_null_pd       PLS_INTEGER;
        l_null_tp       PLS_INTEGER;
        l_null_rnp      PLS_INTEGER;
        l_null_dt       PLS_INTEGER;
        l_null_dt_h     PLS_INTEGER;
        l_null_ap_src   PLS_INTEGER;
        l_null_at_src   PLS_INTEGER;
        l_exists_1101   PLS_INTEGER;
    --    l_hs     NUMBER := tools.GetHistSession;
    BEGIN
        SELECT SUM (CASE WHEN b_pd IS NULL THEN 1 ELSE 0 END),
               SUM (CASE WHEN b_tp IS NULL THEN 1 ELSE 0 END),
               SUM (CASE WHEN b_rnp IS NULL THEN 1 ELSE 0 END),
               SUM (CASE WHEN b_dt IS NULL AND b_tp = 'MR' THEN 1 ELSE 0 END),
               SUM (
                   CASE WHEN b_dt IS NULL AND b_tp = 'HPD' THEN 1 ELSE 0 END),
               SUM (
                   CASE
                       WHEN b_ap_src IS NULL AND b_tp = 'PAP' THEN 1
                       ELSE 0
                   END),
               SUM (
                   CASE
                       WHEN b_at_src IS NULL AND b_tp = 'RPP' THEN 1
                       ELSE 0
                   END),
               SUM ( (SELECT CASE WHEN pd_nst = 1101 THEN 1 ELSE 0 END
                        FROM pc_decision
                       WHERE pd_id = b_pd))
          INTO l_null_pd,
               l_null_tp,
               l_null_rnp,
               l_null_dt,
               l_null_dt_h,
               l_null_ap_src,
               l_null_at_src,
               l_exists_1101
          FROM tmp_pc_block;

        IF l_null_pd > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень не передано зверненнь!');
        END IF;

        IF l_null_tp > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень не передано тип блокування!');
        END IF;

        IF l_null_rnp > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень не передано причину блокування!');
        END IF;

        IF l_null_dt > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень для массового перерахунку не передано дату блокування!');
        END IF;

        IF l_null_dt_h > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень для ручного блокування не передано дату блокування!');
        END IF;

        IF l_null_ap_src > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень для зміни обставин не передано звернення про зміну обставин!');
        END IF;

        IF l_null_at_src > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію блокування рішень по рішенню про припинення надання послуг не передано акту-наказу про припинення надання послуг!');
        END IF;

        IF l_exists_1101 > 0 AND g_check_1101
        THEN
            raise_application_error (
                -20000,
                   'В функцію блокування рішень передано рішення по послузі "'
                || 'Допомога людям з інвалідністю від ВПП ООН до 3250 грн'
                || '"!');
        END IF;

        /* #86934  2023 05 04
        У випадку, якщо користувач під час припинення дії рішення зазначає в "Дата припинення виплати" перше число місяця,
        то необхідно період дії рішення встановлювати по останній день попереднього місяця.

        Для послуг з Ід=249, 267, 269, 268, 664 у разі якщо користувач зазначив будь-яку іншу "Дату припинення виплати" крім першого числа,
        то припинення виплати здійснюється з першого числа наступного місяця, а період дії рішення обмежується останнім днем місяця, який зазначив користувач.

        Для послуг з Ід=265, 248 у разі якщо користувач зазначив будь-яку іншу "Дату припинення виплати" крім першого числа,
        то припинення виплати здійснюється з дня вказаного користувачем, а період дії рішення обмежується мінус один день, який зазначив користувач.

        */
        UPDATE tmp_pc_block b
           SET b.b_id = id_pc_block (b.b_id),
               b.b_stop_dt =
                   (SELECT CASE
                               WHEN TRUNC (b.b_dt) = TRUNC (b.b_dt, 'MM')
                               THEN
                                   TRUNC (b.b_dt, 'MM') - 1
                               WHEN pd_nst IN (249,
                                               267,
                                               269,
                                               268,
                                               664)
                               THEN
                                   LAST_DAY (b.b_dt)
                               WHEN pd_nst IN (265, 248)
                               THEN
                                   TRUNC (b.b_dt) - 1
                               WHEN pd_nst IN (275,
                                               901,
                                               1221,
                                               1201)
                               THEN -- ід=901 (патронат + 1221 помічник + 1201 за період очікування дитини), ід= 275 (діти-сироти).
                                   b.b_dt - 1
                           END
                      FROM pc_decision
                     WHERE pd_id = b.b_pd)
         WHERE 1 = 1;

        INSERT INTO pc_block (pcb_id,
                              pcb_pc,
                              pcb_pd,
                              pcb_tp,
                              pcb_rnp,
                              pcb_lock_pnp_tp,
                              pcb_hs_lock,
                              pcb_exch_code,
                              pcb_ap_src,
                              pcb_acc_stop_dt,
                              pcb_at)
            SELECT b_id,
                   b_pc,
                   b_pd,
                   b_tp,
                   b_rnp,
                   rnp_pnp_tp,
                   b_hs_lock,
                   b_exch_code,
                   NVL (b_ap_src, pd_ap),
                   LAST_DAY (b_dt),
                   b_at_src
              FROM tmp_pc_block
                   JOIN pc_decision ON pd_id = b_pd
                   JOIN uss_ndi.v_ndi_reason_not_pay ON b_rnp = rnp_id;

        INSERT INTO pd_log (pdl_id,
                            pdl_pd,
                            pdl_hs,
                            pdl_st,
                            pdl_message,
                            pdl_st_old,
                            pdl_tp)
            SELECT NULL,
                   t.b_pd,
                   t.b_hs_lock,
                   'PS',
                   CASE
                       WHEN t.b_tp = 'MR'
                       THEN
                              CHR (38)
                           || '119#'
                           || TO_CHAR (LAST_DAY (b_dt) + 1, 'dd.mm.yyyy')
                       WHEN t.b_tp = 'PAP'
                       THEN
                              CHR (38)
                           || '288#'
                           || (SELECT    d.com_org
                                      || '#'
                                      || pc_num
                                      || '#'
                                      || d.pd_num
                                 FROM pc_decision  d
                                      JOIN personalcase pc
                                          ON pc.pc_id = d.pd_pc
                                WHERE d.pd_ap_reason = t.b_ap_src
                                FETCH FIRST ROW ONLY)
                       WHEN t.b_tp = 'HPD'
                       THEN
                           CHR (38) || '199#' || TO_CHAR (b_dt, 'dd.mm.yyyy')
                   END,
                   pd_st,
                   'SYS'
              FROM tmp_pc_block t JOIN pc_decision ON pd_id = t.b_pd
             WHERE t.b_tp IN ('MR', 'PAP', 'HPD');

        UPDATE pc_decision pd
           SET (pd_st, pd_suspend_reason, pd_pcb) =
                   (SELECT 'PS', rnp_code, b_id
                      FROM tmp_pc_block
                           JOIN uss_ndi.v_ndi_reason_not_pay
                               ON b_rnp = rnp_id
                     WHERE b_pd = pd.pd_id
                     FETCH FIRST ROW ONLY)
         WHERE pd_id IN (SELECT b_pd FROM tmp_pc_block);


        accrual_period_block (p_hs);

        -- #89850 2023.08.08 Інформування по Призупинення виплати допомоги ВПО
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('NOTIFY_VPO_ENABLED',
                                                       'IKIS_SYS') =
           'TRUE'
        THEN
            uss_esr.API$AP_SEND_MESSAGE.Notify_VPO_on_Block_Payment;
        END IF;
    END;

    -- IC #101897 -- відключаємо перевірку заборони блокувати допомогу 1101
    PROCEDURE decision_block_pp (p_hs NUMBER)
    IS
    BEGIN
        g_check_1101 := FALSE;
        decision_block (p_hs);
    END;
END API$PC_BLOCK;
/