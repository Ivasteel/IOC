/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_DECISION_EXT
IS
    -- Author  : VANO
    -- Created : 16.12.2021 11:47:58
    -- Purpose : Пакет для тимчасових функцій - які переносяться згодом в API$PC_DECISION

    PROCEDURE Check_another_solution (p_pd_Id    NUMBER,
                                      p_hs       histsession.hs_id%TYPE,
                                      p_com_wu   pc_decision.com_wu%TYPE);

    --==============================================================--
    -- #86901
    -- При створенні рішення по зверненню V зберігати адреси реєстрації та проживання, використовуючи процедуру Api$socialcard.Save_Sc_Address
    -- Для ВПО - дані по адресам беремо з документу 605, для всіх інших допомог - з документу 600 (пишемо і адресу реєстрації і адресу проживання)
    --==============================================================--
    PROCEDURE Save_Sc_Address;

    --==========================================================--
    PROCEDURE Recalc_S_VPO_30_2 (p_rc   rc_candidates.rcc_rc%TYPE,
                                 p_hs   histsession.hs_id%TYPE);

    --==========================================================--
    PROCEDURE Processing_vppun (p_me_id NUMBER, p_hs_id NUMBER);

    --==========================================================--
    --Завантаження результатів виплати по банку (ВПП ООН)
    PROCEDURE Processing_vppun_pay_metod (p_me_id NUMBER, p_hs_id NUMBER);

    --==========================================================--
    --обробка доходів для ВПО
    PROCEDURE Create_Income (                --p_rc rc_candidates.rcc_rc%TYPE,
                             p_recalculates   recalculates%ROWTYPE,
                             p_hs             histsession.hs_id%TYPE);

    PROCEDURE Processing_Income (p_rc   rc_candidates.rcc_rc%TYPE,
                                 p_hs   histsession.hs_id%TYPE);
END API$PC_DECISION_EXT;
/


/* Formatted on 8/12/2025 5:49:10 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_DECISION_EXT
IS
    --==========================================================--
    /*
      FUNCTION gen_pd_num(p_pc_id personalcase.pc_id%TYPE) RETURN VARCHAR2
      IS
        l_cnt INTEGER;
        l_pc_num personalcase.pc_num%TYPE;
      BEGIN
        SELECT COUNT(1) INTO l_cnt FROM pc_decision WHERE pd_pc = p_pc_id AND pd_dt BETWEEN TRUNC(sysdate, 'YYYY') AND LAST_DAY(ADD_MONTHS(TRUNC(sysdate, 'YYYY'), 11)) AND pd_num IS NOT NULL;
    --    dbms_output.put_line(l_cnt);
        SELECT pc_num INTO l_pc_num FROM personalcase WHERE pc_id = p_pc_id;
    --    dbms_output.put_line(l_pc_num);
    --    dbms_output.put_line(l_pc_num||'-'||TO_CHAR(sysdate, 'YYYY')||'-'||(l_cnt + 1));
        RETURN l_pc_num||'-'||TO_CHAR(sysdate, 'YYYY')||'-'||(l_cnt + 1);
      END;
    */
    --==========================================================--
    PROCEDURE Check_another_solution (p_pd_Id    NUMBER,
                                      p_hs       histsession.hs_id%TYPE,
                                      p_com_wu   pc_decision.com_wu%TYPE)
    IS
        l_pd_id      NUMBER (14);
        l_pd_curr    pc_decision%ROWTYPE;
        pay_method   pd_pay_method%ROWTYPE;
        l_lock       TOOLS.t_lockhandler;
        l_num        VARCHAR2 (200);



        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE     p.pdm_pd = p_pd
                     AND p.history_status = 'A'
                     AND p.pdm_is_actual = 'T'
            ORDER BY p.pdm_start_dt ASC, p.pdm_id ASC;
    BEGIN
        --    RETURN;

        SELECT *
          INTO l_pd_curr
          FROM pc_decision
         WHERE pd_id = p_pd_Id;

        --Ініціалізація історіі по поточному зверненню
        API$ACCOUNT.init_tmp_for_pd (p_pd_id);

        -- Шукаємо людей по іншим діючим зверненням
        DELETE FROM TMP_ANOTHER_SOLUTION
              WHERE 1 = 1;

        INSERT INTO TMP_ANOTHER_SOLUTION (TAS_INI_AP,
                                          TAS_INI_DT,
                                          TAS_PD,
                                          TAS_PA,
                                          TAS_SC)
            SELECT ap.ap_id,
                   ap.ap_reg_dt,
                   d.pd_id,
                   d.pd_pa,
                   pf.pdf_sc
              FROM v_tmp_person_for_decision  app
                   JOIN appeal ap ON ap.ap_id = app.pd_ap
                   JOIN pd_family pf
                       ON     pf.pdf_sc = tpp_sc
                          AND (pf.pdf_tp = 'CALC' OR pf.pdf_tp IS NULL)
                   JOIN pc_decision d
                       ON     d.pd_id = pf.pdf_pd
                          AND app.tpp_pd != d.pd_id
                          AND app.pd_nst = d.pd_nst
                          AND app.pd_nst = 664
                          AND d.pd_st IN ('S', 'P')
                          AND ap.ap_reg_dt BETWEEN d.pd_start_dt
                                               AND d.pd_stop_dt
                   JOIN appeal a ON a.ap_id = d.pd_ap
             WHERE     tpp_pd = p_pd_Id
                   AND tpp_app_tp IN ('Z', 'FP', 'FM')
                   AND EXISTS
                           (SELECT 1
                              FROM pd_detail pdd
                             WHERE     pdd.pdd_key = pf.pdf_id
                                   AND ap.ap_reg_dt BETWEEN pdd.pdd_start_dt
                                                        AND pdd.pdd_stop_dt)
                   AND EXISTS
                           (SELECT 1
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = d.pd_id
                                   AND ap.ap_reg_dt BETWEEN pdap_start_dt
                                                        AND pdap_stop_dt
                                   AND pdap.history_status = 'A')
                   AND EXISTS
                           (SELECT 1
                              FROM pd_family pdf
                             WHERE     pdf.pdf_pd = app.pd_id
                                   AND pdf.pdf_sc = app.tpp_sc
                                   AND (   pdf.pdf_tp = 'CALC'
                                        OR pdf.pdf_tp IS NULL)
                                   AND pdf.history_status = 'A');

        -- Якщо інши зверннz є, то потрібно їх обробити
        IF SQL%ROWCOUNT > 0
        THEN
            INSERT INTO tmp_account_ids (x_id)
                SELECT DISTINCT TAS_PA
                  FROM TMP_ANOTHER_SOLUTION;

            API$ACCOUNT.init_tmp (2, NULL);

            UPDATE TMP_ANOTHER_SOLUTION
               SET tas_app_tp =
                       (SELECT MAX (tpp_app_tp)
                          FROM tmp_pa_persons
                         WHERE tpp_pd = tas_pd AND tpp_sc = tas_sc);

            UPDATE TMP_ANOTHER_SOLUTION
               SET tas_oper =
                       (SELECT CASE (MAX (
                                         CASE
                                             WHEN tpp_app_tp = 'Z' THEN 1
                                             ELSE 0
                                         END))
                                   WHEN 1
                                   THEN
                                       'DEL'
                                   ELSE
                                       'UPD'
                               END
                          FROM tmp_pa_persons
                         WHERE tpp_pd = tas_pd AND tpp_sc = tas_sc);

            UPDATE TMP_ANOTHER_SOLUTION t
               SET tas_oper = 'DEL'
             WHERE     tas_app_tp != 'Z'
                   AND EXISTS
                           (SELECT 1
                              FROM TMP_ANOTHER_SOLUTION tt
                             WHERE     tt.tas_pd = t.tas_pd
                                   AND tt.tas_app_tp = 'Z'
                                   AND tt.tas_oper = 'DEL');

            FOR rec IN (SELECT DISTINCT tas_ini_ap,
                                        tas_ini_dt,
                                        tas_pd,
                                        tas_oper
                          FROM TMP_ANOTHER_SOLUTION)
            LOOP
                IF rec.tas_oper = 'DEL'
                THEN
                    API$PC_DECISION.decision_block_pap (
                        rec.tas_pd,
                        l_pd_curr.pd_start_dt - 1,
                        'ANTH_D',
                        rec.tas_ini_ap,
                        p_hs);
                ELSE
                    API$PC_DECISION.decision_block_pap (
                        rec.tas_pd,
                        l_pd_curr.pd_start_dt - 1,
                        'ANTH_D',
                        rec.tas_ini_ap,
                        p_hs);
                    l_pd_id := id_pc_decision (0);

                    INSERT INTO pc_decision (pd_id,
                                             pd_pc,
                                             pd_ap,
                                             pd_pa,
                                             pd_dt,
                                             pd_st,
                                             pd_nst,
                                             com_org,
                                             com_wu,
                                             pd_src,
                                             pd_ps,
                                             pd_src_id,
                                             pd_has_right,
                                             pd_start_dt,
                                             pd_stop_dt,
                                             pd_ap_reason,
                                             pd_scc)
                        SELECT l_pd_id,
                               pd_pc,
                               pd_ap,
                               pd_pa,
                               TRUNC (SYSDATE),
                               'R0',
                               pd_nst,
                               com_org,
                               p_com_wu,
                               'PV'                      AS x_pd_src,
                               pd_ps                     AS x_pd_ps,
                               pd_id,
                               pd_has_right,
                               l_pd_curr.pd_start_dt     AS x_start_dt,
                               pd_stop_dt,
                               rec.tas_ini_ap,             --?????????????????
                               pd_scc
                          FROM pc_decision pd
                         WHERE     pd.pd_id = rec.tas_pd
                               AND NOT EXISTS
                                       (SELECT 1
                                          FROM pd_source pds
                                         WHERE     pds.pds_ap =
                                                   rec.tas_ini_ap
                                               AND pds.pds_pd = rec.tas_pd
                                               AND pds.pds_tp = 'AN');

                    INSERT INTO pd_source (pds_id,
                                           pds_pd,
                                           pds_tp,
                                           pds_ap,
                                           pds_create_dt,
                                           history_status)
                        SELECT 0,
                               pds_pd,
                               pds_tp,
                               pds_ap,
                               pds_create_dt,
                               history_status
                          FROM pd_source
                         WHERE pds_pd = rec.tas_pd AND history_status = 'A'
                        UNION ALL
                        SELECT 0,
                               l_pd_id            AS pds_pd,
                               'AN'               AS pds_tp,
                               rec.tas_ini_ap     AS pds_ap,
                               SYSDATE,
                               'A'
                          FROM DUAL;

                    FOR pm IN pdm (rec.tas_pd)
                    LOOP
                        pay_method := pm;
                    END LOOP;

                    IF pay_method.pdm_pd IS NOT NULL
                    THEN
                        pay_method.pdm_start_dt := l_pd_curr.pd_start_dt;
                        pay_method.pdm_id := NULL;
                        pay_method.pdm_pd := l_pd_id;

                        INSERT INTO pd_pay_method
                             VALUES pay_method;
                    END IF;


                    --Проставляємо номери рішень
                    FOR xx
                        IN (SELECT pd_id,
                                   pc_id,
                                   pc_num,
                                   nst_name,
                                   pa_num
                              FROM (  SELECT pd_id,
                                             pc_id,
                                             pc_num,
                                             nst_name,
                                             pa_num
                                        FROM personalcase,
                                             pc_decision,
                                             uss_ndi.v_ndi_service_type,
                                             pc_account
                                       WHERE     pd_pc = pc_id
                                             AND pd_id = l_pd_id
                                             AND pd_nst = nst_id
                                             AND pd_num IS NULL
                                             AND pd_pa = pa_id
                                    ORDER BY LPAD (pa_num, 10, '0') ASC,
                                             pd_id ASC))
                    LOOP
                        --Вішаємо lock на генерацію номера для ЕОС
                        l_lock :=
                            TOOLS.request_lock (
                                p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                                p_error_msg   =>
                                       'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                                    || xx.pc_num
                                    || '!');

                        l_num := API$PC_DECISION.gen_pd_num (xx.pc_id);

                        UPDATE pc_decision
                           SET pd_num = l_num
                         WHERE pd_id = xx.pd_id;

                        --#81214 20221104
                        API$PC_ATTESTAT.Check_pc_com_org (xx.pd_id,
                                                          SYSDATE,
                                                          p_hs);

                        TOOLS.release_lock (l_lock);
                        --TOOLS.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
                        API$PC_DECISION.write_pd_log (
                            xx.pd_id,
                            p_hs,
                            'R0',
                               CHR (38)
                            || '11#'
                            || l_num
                            || '#'
                            || xx.pc_num
                            || '#'
                            || xx.nst_name,
                            NULL);
                        --#73634 2021.12.02
                        API$ESR_Action.PrepareWrite_Visit_ap_log (
                            xx.pd_id,
                               CHR (38)
                            || '11#'
                            || l_num
                            || '#'
                            || xx.pc_num
                            || '#'
                            || xx.nst_name,
                            NULL);
                    END LOOP;



                    api$pc_decision.recalc_pd_periods_fs (
                        p_pd_id   => rec.tas_pd,
                        p_hs      => p_hs);
                END IF;
            END LOOP;
        END IF;
    END;

    --==========================================================--
    PROCEDURE Save_Sc_Address
    IS
        l_Sca_Src    VARCHAR2 (10) := '35';
        l_Sca_Tp_R   VARCHAR2 (10) := '3';                --3 Місце реєстрації
        l_Sca_Tp_P   VARCHAR2 (10) := '2';                --2 Місце проживання
        l_Sca_Id     NUMBER;
    BEGIN
        FOR rec
            IN (SELECT app_id, app_sc
                  FROM tmp_work_ids
                       JOIN appeal ON ap_id = x_id
                       JOIN ap_person
                           ON     app_ap = ap_id
                              AND ap_person.history_status = 'A'
                 WHERE     ap_tp IN ('V')
                       AND EXISTS
                               (SELECT 1
                                  FROM pc_decision
                                 WHERE pd_ap = ap_id AND pd_nst = 664)
                       AND app_sc IS NOT NULL)
        LOOP
            NULL;

            uss_person.Api$socialcard.Save_Sc_Address (
                p_Sca_Sc          => rec.app_sc,
                p_Sca_Tp          => l_Sca_Tp_R,
                p_Sca_Kaot        =>
                    API$PC_DECISION.get_doc_id (rec.app_id, 605, 1775), --   КАТОТТГ ID V_MF_KOATUU_TEST
                --p_Sca_Nc        => Sc_Address.Sca_Nc%TYPE := NULL,
                --p_Sca_Country   => ,
                --p_Sca_Region    => ,
                --p_Sca_District  => ,
                p_Sca_Postcode    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1776), --   Індекс ID v_mf_index
                --p_Sca_City      => ,
                p_Sca_Street      =>
                    NVL (
                        API$PC_DECISION.get_doc_string (rec.app_id,
                                                        605,
                                                        1777), --   Вулиця (вибір із довідника) ID V_NDI_STREET
                        API$PC_DECISION.get_doc_string (rec.app_id,
                                                        605,
                                                        1785) --   Вулиця (введення, у випадку відсутності в довіднику) STRING V_NDI_STREET
                                                             ),
                p_Sca_Building    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1778), --   Будинок STRING
                p_Sca_Block       =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1779), --   Корпус STRING
                p_Sca_Apartment   =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1788), --   Квартира STRING
                --p_Sca_Note      => Sc_Address.Sca_Note%TYPE := NU(rec.app_id
                p_Sca_Src         => l_Sca_Src,
                p_Sca_Create_Dt   => SYSDATE,
                o_Sca_Id          => l_Sca_Id);

            uss_person.Api$socialcard.Save_Sc_Address (
                p_Sca_Sc          => rec.app_sc,
                p_Sca_Tp          => l_Sca_Tp_P,
                p_Sca_Kaot        =>
                    API$PC_DECISION.get_doc_id (rec.app_id, 605, 1781), --   КАТОТТГ ID V_MF_KOATUU_TEST
                --p_Sca_Nc        => Sc_Address.Sca_Nc%TYPE := NULL,
                --p_Sca_Country => ,
                --p_Sca_Region    => ,
                --p_Sca_District  => ,
                p_Sca_Postcode    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1782), --   Індекс ID v_mf_index
                --p_Sca_City      => ,
                p_Sca_Street      =>
                    NVL (
                        API$PC_DECISION.get_doc_string (rec.app_id,
                                                        605,
                                                        1783), --   Вулиця (вибір із довідника) ID V_NDI_STREET
                        API$PC_DECISION.get_doc_string (rec.app_id,
                                                        605,
                                                        1786) --   Вулиця (введення, у випадку відсутності в довіднику) STRING V_NDI_STREET
                                                             ),
                p_Sca_Building    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1784), --   Будинок STRING
                p_Sca_Block       =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1787), --   Корпус STRING
                p_Sca_Apartment   =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 605, 1780), --   Квартира STRING
                --p_Sca_Note      => Sc_Address.Sca_Note%TYPE := NU(rec.app_id
                p_Sca_Src         => l_Sca_Src,
                p_Sca_Create_Dt   => SYSDATE,
                o_Sca_Id          => l_Sca_Id);
        END LOOP;

        FOR rec
            IN (SELECT app_id, app_sc
                  FROM tmp_work_ids
                       JOIN appeal ON ap_id = x_id
                       JOIN ap_person
                           ON     app_ap = ap_id
                              AND ap_person.history_status = 'A'
                 WHERE     ap_tp IN ('V')
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM pc_decision
                                 WHERE pd_ap = ap_id AND pd_nst = 664)
                       AND EXISTS
                               (SELECT 1
                                  FROM pc_decision
                                 WHERE pd_ap = ap_id)
                       AND app_sc IS NOT NULL)
        LOOP
            NULL;
            uss_person.Api$socialcard.Save_Sc_Address (
                p_Sca_Sc          => rec.app_sc,
                p_Sca_Tp          => l_Sca_Tp_R,
                p_Sca_Kaot        =>
                    API$PC_DECISION.get_doc_id (rec.app_id, 600, 580), --  КАТОТТГ адреси реєстрації ID V_MF_KOATUU_TEST
                --p_Sca_Nc        => Sc_Address.Sca_Nc%TYPE := NULL,
                p_Sca_Country     =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 591), -- Країна адреси реєстрації STRING
                p_Sca_Region      =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 589), --  Область адреси реєстрації STRING
                p_Sca_District    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 588), --  Район адреси реєстрації STRING
                p_Sca_Postcode    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 587), --  Індекс адреси реєстрації ID v_mf_index
                p_Sca_City        =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 586), --  Місто адреси реєстрації STRING
                p_Sca_Street      =>
                    NVL (
                        API$PC_DECISION.get_doc_string (rec.app_id, 600, 585), --  Вулиця адреси реєстрації (довідник) ID V_NDI_STREET
                        API$PC_DECISION.get_doc_string (rec.app_id, 600, 787) --  Вулиця адреси реєстрації STRING V_NDI_STREET
                                                                             ),
                p_Sca_Building    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 584), --  Будинок адреси реєстрації STRING
                p_Sca_Block       =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 583), --  Корпус адреси реєстрації STRING
                p_Sca_Apartment   =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 582), --  Квартира адреси реєстрації STRING
                --p_Sca_Note      => Sc_Address.Sca_Note%TYPE := NU(rec.app_id
                p_Sca_Src         => l_Sca_Src,
                p_Sca_Create_Dt   => SYSDATE,
                o_Sca_Id          => l_Sca_Id);

            uss_person.Api$socialcard.Save_Sc_Address (
                p_Sca_Sc          => rec.app_sc,
                p_Sca_Tp          => l_Sca_Tp_P,
                p_Sca_Kaot        =>
                    API$PC_DECISION.get_doc_id (rec.app_id, 600, 604), --  КАТОТТГ адреси проживання ID V_MF_KOATUU_TEST
                --p_Sca_Nc        => Sc_Address.Sca_Nc%TYPE := NULL,
                p_Sca_Country     =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 603), --  Країна адреси проживання STRING
                p_Sca_Region      =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 601), --  Область адреси проживання STRING
                p_Sca_District    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 600), --  Район адреси проживання STRING
                p_Sca_Postcode    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 599), --  Індекс адреси проживання ID v_mf_index
                p_Sca_City        =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 598), --  Місто адреси проживання STRING
                p_Sca_Street      =>
                    NVL (
                        API$PC_DECISION.get_doc_string (rec.app_id, 600, 597), --  Вулиця адреси проживання (довідник) ID V_NDI_STREET
                        API$PC_DECISION.get_doc_string (rec.app_id, 600, 788) --  Вулиця адреси проживання STRING V_NDI_STREET
                                                                             ),
                p_Sca_Building    =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 596), --  Будинок адреси проживання STRING
                p_Sca_Block       =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 595), --  Корпус адреси проживання STRING
                p_Sca_Apartment   =>
                    API$PC_DECISION.get_doc_string (rec.app_id, 600, 594), --  Квартира адреси проживання STRING
                --p_Sca_Note      => Sc_Address.Sca_Note%TYPE := NU(rec.app_id
                p_Sca_Src         => l_Sca_Src,
                p_Sca_Create_Dt   => SYSDATE,
                o_Sca_Id          => l_Sca_Id);
        END LOOP;
    END;

    --==========================================================--
    PROCEDURE Recalc_S_VPO_30_2 (p_rc   rc_candidates.rcc_rc%TYPE,
                                 p_hs   histsession.hs_id%TYPE)
    IS
        l_pnp_code   VARCHAR2 (20) := 'OR332_30_2';
    --   l_recalculates recalculates%ROWTYPE;
    BEGIN
        --    SELECT * INTO l_recalculates FROM recalculates WHERE rc_id = p_rc;
        --Підготуємо перелік окупованих теріторій.
        --    API$ACCOUNT.init_tmp_kaots_all_TO(l_recalculates.rc_month);

        --IF l_recalculates.rc_month >= to_date('01.04.2024', 'dd.mm.yyyy') THEN
        --  l_recalculates.rc_month := to_date('01.03.2024', 'dd.mm.yyyy');
        --END IF;

        API$PC_BLOCK.CLEAR_BLOCK;

        /*
        3. Призупинити виплату рішень, у яких призначено допомогу особам станом на 29.02.2024 (в періоді дії рішень є 29.02.2024 ),
           у яких в актуальній довідці ВПО nda_ndt=10052 в атрибуті з Ід=4492 зазначено КАТОТТГ, у якого відсутня дата завершення тимчасової окупації.
        */
        INSERT INTO tmp_pc_block (b_id,
                                  b_pc,
                                  b_pd,
                                  b_tp,
                                  b_rnp,
                                  b_locl_pnp_tp,
                                  b_hs_lock,
                                  b_ap_src,
                                  b_dt)
            WITH
                pd
                AS
                    (SELECT DISTINCT
                            pd_pc,
                            pd_id,
                            'MR'                             AS x_b_tp,
                            np.rnp_id,
                            np.rnp_pnp_tp,
                            p_hs,
                            pd_ap,
                            ADD_MONTHS (rc.rc_month, -1)     AS X_stop_dt
                       FROM recalculates  rc
                            JOIN rc_candidates c ON c.rcc_rc = rc_id
                            JOIN pc_decision ON rcc_pd = pd_id
                            JOIN Pd_Pay_Method pm
                                ON     pm.pdm_pd = pd_id
                                   AND pm.pdm_is_actual = 'T'
                                   AND pm.history_status = 'A'
                            JOIN uss_ndi.V_NDI_REASON_NOT_PAY np
                                ON     np.rnp_pay_tp = pm.pdm_pay_tp
                                   AND np.rnp_code = l_pnp_code
                                   AND np.history_status = 'A'
                      WHERE rc_id = p_rc AND pd_st = 'S' AND pd_nst = 664)
            SELECT id_pc_block (NULL),
                   pd_pc,
                   pd_id,
                   x_b_tp,
                   rnp_id,
                   rnp_pnp_tp,
                   p_hs,
                   pd_ap,
                   X_stop_dt
              FROM pd;

        API$PC_BLOCK.decision_block (p_hs);
    END;

    --==========================================================--
    /*
      PROCEDURE Copy_Decision(p_pd_id         NUMBER,
                              p_pd_new IN OUT NUMBER,
                              p_month_dt      DATE,
                              p_hs            NUMBER
                              ) IS
        l_sql_cnt NUMBER;
        pay_method  pd_pay_method%ROWTYPE;
        l_lock      TOOLS.t_lockhandler;
        l_num       VARCHAR2(200);
        p_new_id    NUMBER;
        Cursor pdm(p_pd NUMBER) IS
           SELECT p.*
           FROM pd_pay_method p
           WHERE p.pdm_pd = p_pd
                 AND p.history_status = 'A'
           ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;

      BEGIN
        p_new_id := id_pc_decision(0);

        INSERT INTO pc_decision (pd_id, pd_pc, pd_ap, pd_pa,
                               pd_dt, pd_st, pd_nst, com_org, com_wu,
                               pd_src, pd_ps,
                               pd_src_id, pd_has_right, pd_start_dt, pd_stop_dt,
                               pd_ap_reason, pd_scc)
        SELECT p_new_id, pd_pc, pd_ap, p_pa_id,
               TRUNC(sysdate), 'S' AS x_st, pd_nst, p_dest_org, com_wu,
               'PV' AS x_pd_src, pd_ps AS x_pd_ps,
               pd_id, pd_has_right, p_start_dt, pd_stop_dt,
               p_ap_id,  pd_scc
        FROM pc_decision pd
        WHERE pd.pd_id = p_pd_id;

              FOR pm IN pdm(p_pd_id) LOOP
                pay_method := pm;
              END LOOP;

              IF pay_method.pdm_pd IS NOT NULL THEN
                pay_method.pdm_id := NULL;
                pay_method.pdm_pd := p_new_id;
                pay_method.pdm_start_dt := p_start_dt;
                INSERT INTO pd_pay_method VALUES pay_method;
              END IF;

              INSERT INTO pd_right_log (prl_id, prl_pd, prl_nrr, prl_result, prl_hs_rewrite, prl_calc_result, prl_calc_info)
              SELECT 0 AS x_id, p_new_id AS x_pd, prl_nrr, prl_result, prl_hs_rewrite, prl_calc_result, prl_calc_info
              FROM pd_right_log prl
              WHERE prl.prl_pd = p_pd_id;

              INSERT INTO pd_features (pde_id, pde_pd, pde_nft, pde_val_int, pde_val_sum, pde_val_id, pde_val_dt, pde_val_string, pde_pdf)
              SELECT 0 AS x_id, p_new_id AS x_pd, pde_nft, pde_val_int, pde_val_sum, pde_val_id, pde_val_dt, pde_val_string, pde_pdf
              FROM pd_features pde
              WHERE pde.pde_pd = p_pd_id;

              INSERT INTO pd_family (pdf_id, pdf_pd, pdf_sc, pdf_birth_dt)
              SELECT 0 AS x_id, p_new_id AS x_pd, pdf_sc, pdf_birth_dt
              FROM pd_family pdf
              WHERE pdf.pdf_pd = p_pd_id;

              DELETE FROM tmp_work_set1 WHERE 1=1;
              INSERT INTO tmp_work_set1 (x_id1, x_id2)
              SELECT pdp_id, id_pd_payment(0)
              FROM pd_payment pdp
              WHERE pdp.pdp_pd = p_pd_id
                AND pdp.pdp_stop_dt > p_start_dt;
              l_sql_cnt := SQL%ROWCOUNT;
              IF l_sql_cnt > 0 THEN
                INSERT INTO pd_payment (pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status)
                SELECT x_id2, p_new_id AS x_pd, pdp_npt,
                       CASE
                         WHEN pdp_start_dt < p_start_dt THEN
                           p_start_dt
                         ELSE
                           pdp_start_dt
                       END AS x_start_dt,
                       pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status
                FROM pd_payment pdp
                     JOIN tmp_work_set1 ON x_id1 = pdp_id;

                INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
                SELECT 0 AS x_id, x_id2, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
                       CASE
                         WHEN pdd_start_dt < p_start_dt THEN
                           p_start_dt
                         ELSE
                           pdd_start_dt
                       END AS x_start_dt,
                       pdd_stop_dt, pdd_npt
                FROM pd_detail pdd
                     JOIN tmp_work_set1 ON x_id1 = pdd_pdp;
              ELSE
                INSERT INTO tmp_work_set1 (x_id1, x_id2)
                SELECT pdp_id, id_pd_payment(0)
                FROM pd_payment pdp
                WHERE pdp.pdp_pd = p_pd_id
                  AND (pdp.pdp_stop_dt + 1) > p_start_dt ;

                INSERT INTO pd_payment (pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status)
                SELECT x_id2, p_new_id AS x_pd, pdp_npt,
                       CASE
                         WHEN pdp_start_dt < p_start_dt THEN
                           p_start_dt
                         ELSE
                           pdp_start_dt
                       END AS x_start_dt,
                       pdp_stop_dt,
                       pdp_sum, pdp_hs_ins, pdp_hs_del, history_status
                FROM pd_payment pdp
                     JOIN tmp_work_set1 ON x_id1 = pdp_id;

                INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
                SELECT 0 AS x_id, x_id2, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
                       CASE
                         WHEN pdd_start_dt < P_start_dt THEN
                           P_start_dt
                         ELSE
                           pdd_start_dt
                       END AS x_start_dt,
                       pdd_stop_dt,
                       pdd_npt
                FROM pd_detail pdd
                     JOIN tmp_work_set1 ON x_id1 = pdd_pdp;

              END IF;

              api$pc_decision.recalc_pd_periods_fs(p_new_id, p_hs);

              --Проставляємо номери рішень
              FOR xx IN (SELECT pd_id, pc_id, pc_num, nst_name, pa_num
                         FROM (SELECT pd_id, pc_id, pc_num, nst_name, pa_num
                               FROM personalcase, pc_decision, uss_ndi.v_ndi_service_type, pc_account
                               WHERE pd_pc = pc_id
                                 AND pd_id = p_new_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                                 AND pd_pa = pa_id
                         ORDER BY LPAD(pa_num, 10, '0') ASC, pd_id ASC)
                         )
              LOOP
                --Вішаємо lock на генерацію номера для ЕОС
                l_lock := TOOLS.request_lock(p_descr => 'CALC_PA_NUMS_PC_'||xx.pc_id, p_error_msg => 'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'||xx.pc_num||'!');

                l_num := API$PC_DECISION.gen_pd_num(xx.pc_id);
                UPDATE pc_decision
                  SET pd_num = l_num
                  WHERE pd_id = xx.pd_id;
                --#81214 20221104
                API$PC_ATTESTAT.Check_pc_com_org( xx.pd_id, SYSDATE, p_hs );

                TOOLS.release_lock(l_lock);
                --TOOLS.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
                API$PC_DECISION.write_pd_log(xx.pd_id, p_hs, 'S', CHR(38)||'11#'||l_num||'#'||xx.pc_num||'#'||xx.nst_name, NULL);
                --#73634 2021.12.02
                API$ESR_Action.PrepareWrite_Visit_ap_log(xx.pd_id,  CHR(38)||'11#'||l_num||'#'||xx.pc_num||'#'||xx.nst_name, NULL);
                API$ESR_Action.PrepareCopy_ESR2Visit(p_ap_id, 'V', CHR(38)||'11#'||l_num||'#'||xx.pc_num||'#'||xx.nst_name);
              END LOOP;
      END;
    */
    --==========================================================--
    PROCEDURE Processing_vppun (p_me_id NUMBER, p_hs_id NUMBER)
    IS
        l_nst    NUMBER := 1101;
        l_npt    NUMBER := 853;
        l_cnt    NUMBER;
        --    l_hs  NUMBER;
        --l_lock_init TOOLS.t_lockhandler;
        l_lock   TOOLS.t_lockhandler;
        l_num    pc_account.pa_num%TYPE;
    BEGIN
        --    l_hs := uss_esr.tools.GetHistSession();
        --Генеруємо необхідну кількість нових Особових рахунків
        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1, x_id2)
            SELECT DISTINCT s.mvrr_pc AS x_pc, l_nst AS x_nst
              FROM me_vppun_result_rows  r
                   JOIN me_vppun_request_rows s
                       ON s.mvrr_me = r.mvsr_me AND s.mvrr_id = r.mvsr_mvrr
             WHERE     r.mvsr_st = 'O'
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_account
                             WHERE pa_pc = s.mvrr_pc AND pa_nst = l_nst)
                   AND s.mvrr_me = p_me_id;

        /*
              AND s.mvrr_me = 501
              AND
              (   s.mvrr_pd = 754150
               OR s.mvrr_pd = 754279
               OR s.mvrr_pd = 754282
               OR s.mvrr_pd = 754292
              )*/

        INSERT INTO pc_account (pa_id, pa_pc, pa_nst)
            SELECT DISTINCT 0 AS x_pa_id, x_id1 AS x_pc, x_id2 AS x_nst
              FROM tmp_work_set2;

        FOR xx IN (  SELECT pa_id, pc_id, pc_num
                       FROM tmp_work_set2
                            JOIN pc_account ON pa_pc = x_id1
                            JOIN personalcase ON pc_id = x_id1
                      WHERE pa_num IS NULL
                   ORDER BY pa_id ASC)
        LOOP
            --Вішаємо lock на генерацію номера для ОР
            l_lock :=
                TOOLS.request_lock (
                    p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                    p_error_msg   =>
                           'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                        || xx.pc_num
                        || '!');

            l_num := API$PC_DECISION.gen_pa_num (xx.pc_id);

            UPDATE pc_account
               SET pa_num = l_num
             WHERE pa_id = xx.pa_id;

            --Формвання записів в таблицю обробки - для можливості обробки звереннь на нові держутримання
            TOOLS.release_lock (l_lock);
        END LOOP;


        -- Сформуємо буфер
        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1)
            SELECT s.mvrr_pd,
                   (SELECT MAX (pd_id)
                      FROM pc_decision pd
                     WHERE     pd.pd_src_id = s.mvrr_pd
                           AND pd.pd_nst = 1101
                           AND pd.pd_st = 'S')
                       AS pd_id,
                   (SELECT MAX (pa_id)
                      FROM pc_account
                     WHERE pa_pc = s.mvrr_pc AND pa_nst = l_nst)
                       AS x_pa,
                   r.mvsr_id,
                   TRUNC (me.me_month, 'MM')
                       AS x_start_dt,
                   LAST_DAY (me.me_month)
                       AS x_stop_dt,
                   TO_NUMBER (r.mvsr_payout DEFAULT 0 ON CONVERSION ERROR,
                              '999999.999')
                       AS x_sum
              FROM me_vppun_result_rows  r
                   JOIN me_vppun_request_rows s
                       ON s.mvrr_me = r.mvsr_me AND s.mvrr_id = r.mvsr_mvrr
                   JOIN mass_exchanges me ON me.me_id = s.mvrr_me
                   LEFT JOIN pc_decision pd
                       ON     pd.pd_src_id = s.mvrr_pd
                          AND pd.pd_nst = l_nst
                          AND pd.pd_st = 'S'
             WHERE r.mvsr_st = 'O' AND s.mvrr_me = p_me_id;

        /*
              AND s.mvrr_me = 501
              AND
              (   s.mvrr_pd = 754150
        --       OR s.mvrr_pd = 754279
        --       OR s.mvrr_pd = 754282
        --       OR s.mvrr_pd = 754292
              );*/


        -- 'I' нове рішення
        -- 'DPL' існуюче рішення, вже додано грощі
        -- 'U' існуюче рішення, грощі потрібно додати
        UPDATE tmp_work_set2 t
           SET t.x_string1 =
                   CASE
                       WHEN x_id2 IS NULL
                       THEN
                           'I'
                       WHEN (SELECT COUNT (1)
                               FROM pd_payment p
                              WHERE     pdp_pd = x_id2
                                    AND p.pdp_start_dt = t.x_dt1
                                    AND p.history_status = 'A') >
                            0
                       THEN
                           'DPL'
                       ELSE
                           'U'
                   END
         WHERE 1 = 1;

        -- Для нових потрібно залити нові pd_id
        UPDATE tmp_work_set2 t
           SET t.x_id2 = id_pc_decision (0)
         WHERE t.x_string1 = 'I';

        --Тут обробимо INSERT pc_decision
        INSERT INTO pc_decision (pd_id,
                                 pd_pc,
                                 pd_ap,
                                 pd_pa,
                                 pd_dt,
                                 pd_st,
                                 pd_nst,
                                 com_org,
                                 com_wu,
                                 pd_src,
                                 pd_ps,
                                 pd_src_id,
                                 pd_has_right,
                                 pd_start_dt,
                                 pd_stop_dt,
                                 pd_ap_reason,
                                 pd_scc)
            SELECT t.x_pd_new,
                   pd_pc,
                   pd_ap,
                   t.x_pa,
                   TRUNC (SYSDATE),
                   'S'      AS x_st,
                   1101,
                   com_org,
                   com_wu,
                   'PV'     AS x_pd_src,
                   pd_ps,
                   t.x_pd_base,
                   pd_has_right,
                   t.x_start_dt,
                   t.x_stop_dt,
                   pd_ap_reason,
                   pd_scc
              FROM pc_decision  pd
                   JOIN (SELECT x_id1     AS x_pd_base,
                                x_id2     AS x_pd_new,
                                x_id3     AS x_pa,
                                x_dt1     AS x_start_dt,
                                x_dt2     AS x_stop_dt
                           FROM tmp_work_set2
                          WHERE x_string1 = 'I') t
                       ON pd.pd_id = t.x_pd_base;

        INSERT INTO pd_pay_method (pdm_id,
                                   pdm_pd,
                                   pdm_start_dt,
                                   pdm_stop_dt,
                                   history_status,
                                   pdm_ap_src,
                                   pdm_pay_tp,
                                   pdm_index,
                                   pdm_kaot,
                                   pdm_street,
                                   pdm_ns,
                                   pdm_building,
                                   pdm_block,
                                   pdm_apartment,
                                   pdm_nb,
                                   pdm_account,
                                   pdm_nd,
                                   pdm_pay_dt,
                                   pdm_hs,
                                   pdm_scc,
                                   pdm_is_actual,
                                   pdm_nd_num)
            SELECT 0     AS x_pdm_id,
                   t.x_pd_new,
                   t.x_start_dt,
                   t.x_stop_dt,
                   history_status,
                   pdm_ap_src,
                   pdm_pay_tp,
                   pdm_index,
                   pdm_kaot,
                   pdm_street,
                   pdm_ns,
                   pdm_building,
                   pdm_block,
                   pdm_apartment,
                   pdm_nb,
                   pdm_account,
                   pdm_nd,
                   pdm_pay_dt,
                   pdm_hs,
                   pdm_scc,
                   pdm_is_actual,
                   pdm_nd_num
              FROM pd_pay_method
                   JOIN (SELECT x_id1     AS x_pd_base,
                                x_id2     AS x_pd_new,
                                x_dt1     AS x_start_dt,
                                x_dt2     AS x_stop_dt
                           FROM tmp_work_set2
                          WHERE x_string1 = 'I') t
                       ON pdm_pd = t.x_pd_base
             WHERE history_status = 'A' AND pdm_is_actual = 'T';

        INSERT INTO pd_family (pdf_id,
                               pdf_pd,
                               pdf_sc,
                               pdf_birth_dt,
                               history_status,
                               pdf_hs_ins,
                               pdf_tp,
                               pdf_start_dt,
                               pdf_stop_dt)
            SELECT 0     AS x_id,
                   t.x_pd_new,
                   pdf_sc,
                   pdf_birth_dt,
                   'A',
                   pdf_hs_ins,
                   pdf_tp,
                   pdf_start_dt,
                   pdf_stop_dt
              FROM pd_family  pdf
                   JOIN (SELECT x_id1 AS x_pd_base, x_id2 AS x_pd_new
                           FROM tmp_work_set2
                          WHERE x_string1 = 'I') t
                       ON pdf.pdf_pd = t.x_pd_base
             WHERE NVL (pdf.history_status, 'A') = 'A';

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_nft,
                                 pde_val_int,
                                 pde_val_sum,
                                 pde_val_id,
                                 pde_val_dt,
                                 pde_val_string,
                                 pde_pdf)
            SELECT 0                                         AS x_id,
                   t.x_pd_new,
                   pde_nft,
                   pde_val_int,
                   pde_val_sum,
                   pde_val_id,
                   pde_val_dt,
                   pde_val_string,
                   (SELECT MAX (pdf_id)
                      FROM pd_family pdf_n
                     WHERE     pdf_n.pdf_pd = t.x_pd_new
                           AND pdf_n.pdf_sc = pdf.pdf_sc)    AS x_pdf
              FROM pd_features  pde
                   JOIN (SELECT x_id1 AS x_pd_base, x_id2 AS x_pd_new
                           FROM tmp_work_set2
                          WHERE x_string1 = 'I') t
                       ON pde.pde_pd = t.x_pd_base
                   LEFT JOIN pd_family pdf ON pdf.pdf_id = pde.pde_pdf;

        --Тут обробимо UPDATE pc_decision
        UPDATE pc_decision pd
           SET pd.pd_stop_dt =
                   (SELECT t.x_dt2
                      FROM tmp_work_set2 t
                     WHERE t.x_id2 = pd_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_string1 = 'U' AND x_id2 = pd_id);

        UPDATE pd_pay_method
           SET pdm_is_actual = 'F'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_string1 = 'U' AND x_id2 = pdm_pd);

        INSERT INTO pd_pay_method (pdm_id,
                                   pdm_pd,
                                   pdm_start_dt,
                                   pdm_stop_dt,
                                   history_status,
                                   pdm_ap_src,
                                   pdm_pay_tp,
                                   pdm_index,
                                   pdm_kaot,
                                   pdm_street,
                                   pdm_ns,
                                   pdm_building,
                                   pdm_block,
                                   pdm_apartment,
                                   pdm_nb,
                                   pdm_account,
                                   pdm_nd,
                                   pdm_pay_dt,
                                   pdm_hs,
                                   pdm_scc,
                                   pdm_is_actual,
                                   pdm_nd_num)
            SELECT 0        AS x_pdm_id,
                   t.x_pd_new,
                   t.x_start_dt,
                   t.x_stop_dt,
                   history_status,
                   pdm_ap_src,
                   pdm_pay_tp,
                   pdm_index,
                   pdm_kaot,
                   pdm_street,
                   pdm_ns,
                   pdm_building,
                   pdm_block,
                   pdm_apartment,
                   pdm_nb,
                   pdm_account,
                   pdm_nd,
                   (CASE
                        WHEN PDM_PAY_DT > 25 OR PDM_PAY_DT < 4 THEN 4
                        ELSE pdm_pay_dt
                    END)    AS pdm_pay_dt,
                   pdm_hs,
                   pdm_scc,
                   pdm_is_actual,
                   pdm_nd_num
              FROM pd_pay_method
                   JOIN (SELECT x_id1     AS x_pd_base,
                                x_id2     AS x_pd_new,
                                x_dt1     AS x_start_dt,
                                x_dt2     AS x_stop_dt
                           FROM tmp_work_set2
                          WHERE x_string1 = 'U') t
                       ON pdm_pd = t.x_pd_base
             WHERE history_status = 'A' AND pdm_is_actual = 'T';

        -----------------------------------------------
        --Раздамо номери рішень
        -----------------------------------------------
        FOR xx
            IN (SELECT pd_id,
                       pc_id,
                       pc_num,
                       nst_name,
                       pa_num
                  FROM (  SELECT pd_id,
                                 pc_id,
                                 pc_num,
                                 nst_name,
                                 pa_num
                            FROM personalcase
                                 JOIN pc_decision ON pd_pc = pc_id
                                 JOIN pc_account ON pd_pa = pa_id
                                 JOIN uss_ndi.v_ndi_service_type
                                     ON pd_nst = nst_id
                                 JOIN tmp_work_set2 t ON pd_id = t.x_id2
                        ORDER BY LPAD (pa_num, 10, '0') ASC, pd_id ASC))
        LOOP
            --Вішаємо lock на генерацію номера для ЕОС
            l_lock :=
                TOOLS.request_lock (
                    p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                    p_error_msg   =>
                           'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                        || xx.pc_num
                        || '!');

            l_num := API$PC_DECISION.gen_pd_num (xx.pc_id);

            UPDATE pc_decision
               SET pd_num = l_num
             WHERE pd_id = xx.pd_id;

            TOOLS.release_lock (l_lock);
            API$PC_DECISION.Update_PA_Org (xx.pd_id, 'S', 'S');
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                p_hs_id,
                'S',
                   CHR (38)
                || '11#'
                || l_num
                || '#'
                || xx.pc_num
                || '#'
                || xx.nst_name,
                NULL);
        END LOOP;

        --
        --Тут обробимо загальне для INSERT + UPDATE
        --
        -- Для нових платежів потрібно залити нові pdp_id (x_id4)
        UPDATE tmp_work_set2 t
           SET t.x_id4 = id_pd_payment (0)
         WHERE t.x_string1 IN ('I', 'U');


        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                pdp_hs_ins,
                                history_status,
                                pdp_src)
            WITH
                tmp_pdp
                AS
                    (SELECT x_id2      AS x_pd_new,
                            x_id4      AS x_pdp_new,
                            x_dt1      AS x_start_dt,
                            x_dt2      AS x_stop_dt,
                            x_sum1     AS x_sum
                       FROM tmp_work_set2
                      WHERE x_string1 IN ('I', 'U'))
            SELECT t.x_pdp_new,
                   t.x_pd_new,
                   l_npt,
                   x_start_dt,
                   x_stop_dt,
                   x_sum,
                   p_hs_id,
                   'A',
                   ''
              FROM tmp_pdp t;

        INSERT INTO pd_detail (pdd_id,
                               pdd_pdp,
                               pdd_row_order,
                               pdd_row_name,
                               pdd_value,
                               pdd_key,
                               pdd_ndp,
                               pdd_start_dt,
                               pdd_stop_dt,
                               pdd_npt)
            WITH
                tmp_pdp
                AS
                    (SELECT x_id2      AS x_pd_new,
                            x_id4      AS x_pdp_new,
                            x_dt1      AS x_start_dt,
                            x_dt2      AS x_stop_dt,
                            x_sum1     AS x_sum,
                            pc_sc      AS x_sc
                       FROM tmp_work_set2
                            JOIN pc_decision ON pd_id = x_id2
                            JOIN personalcase ON pc_id = pd_pc
                      WHERE x_string1 IN ('I', 'U'))
            SELECT 0
                       AS x_pdd_id,
                   x_pdp_new,
                   300,
                   'Виплати від ВПП ООН',
                   x_sum,
                   (SELECT MAX (pdf_id)
                      FROM pd_family
                     WHERE pdf_pd = x_pd_new AND pdf_sc = x_sc)
                       AS x_pdd_key,
                   300
                       AS x_pdd_ndp,
                   x_start_dt,
                   x_stop_dt,
                   l_npt
              FROM tmp_pdp;

        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            WITH
                tmp_pdap
                AS
                    (SELECT x_id2     AS x_pd_new,
                            x_dt1     AS x_start_dt,
                            x_dt2     AS x_stop_dt
                       FROM tmp_work_set2
                      WHERE x_string1 IN ('I', 'U'))
            SELECT 0     AS x_pdap_id,
                   x_pd_new,
                   x_start_dt,
                   x_stop_dt,
                   'A',
                   p_hs_id
              FROM tmp_pdap;

        /*
            SELECT x_id1 AS x_pd_base, x_id2 AS x_pd_new, x_id3 AS x_pa, x_id5 AS x_mvsr,
                   x_dt1 AS x_start_dt, x_dt2 AS x_stop_dt, x_sum1 AS x_sum, x_string1 AS x_mode
            FROM tmp_work_set2;
        */

        --RETURN;
        --Заповнюємо accrual, якщо немає
        INSERT INTO accrual (ac_id,
                             ac_pc,
                             ac_month,
                             ac_st,
                             history_status,
                             com_org)
            SELECT DISTINCT 0,
                            pa.pa_pc,
                            t.x_dt1,
                            'R',
                            'A',
                            pa.pa_org
              FROM tmp_work_set2 t JOIN pc_account pa ON pa.pa_id = t.x_id3
             WHERE     t.x_string1 IN ('I', 'U')
                   AND NOT EXISTS
                           (SELECT ac_id
                              FROM accrual  ac
                                   JOIN pc_account pa ON pa.pa_pc = ac.ac_pc
                             WHERE     pa.pa_id = t.x_id3
                                   AND TRUNC (ac_month, 'MM') =
                                       TRUNC (t.x_dt1, 'MM'));

        --Заповнюємо ac_id (знов x_id4)
        UPDATE tmp_work_set2 t
           SET t.x_id4 =
                   (SELECT ac_id
                      FROM accrual  ac
                           JOIN pc_account pa ON pa.pa_pc = ac.ac_pc
                     WHERE pa.pa_id = t.x_id3 AND ac_month = t.x_dt1--AND ac.com_org = pa.pa_org
                                                                    )
         WHERE t.x_string1 IN ('I', 'U');

        SELECT COUNT (1)
          INTO l_cnt
          FROM tmp_work_set2 t
         WHERE t.x_string1 IN ('I', 'U') AND t.x_id4 IS NULL;

        IF l_cnt > 0
        THEN
            raise_application_error (-20000, 'Є пусті x_ac');
        END IF;

        /*
        Створення рішень по ВПП ООН по банку з позначкою в AC_Detail в полі ACD_IMP_PR_NUM - прописуємо там 1

        Це стосується лише по типу ВПП ООН (банк)
        */
        INSERT INTO ac_detail (acd_id,
                               acd_ac,
                               acd_op,
                               acd_npt,
                               acd_start_dt,
                               acd_stop_dt,
                               acd_sum,
                               acd_month_sum,
                               acd_delta_recalc,
                               acd_delta_pay,
                               acd_pd,
                               acd_ac_start_dt,
                               acd_ac_stop_dt,
                               acd_st,
                               history_status,
                               acd_imp_pr_num)
            SELECT 0,
                   t.x_id4     AS x_ac,
                   1           AS x_op,
                   l_npt,
                   ac.ac_month,
                   LAST_DAY (ac.ac_month),
                   t.x_sum1,
                   NULL,
                   NULL,
                   NULL,
                   t.x_id2,
                   t.x_dt1,
                   t.x_dt2,
                   'R',
                   'A',
                   /*CASE WHEN ( SELECT COUNT(1)
                               FROM pd_pay_method m
                               WHERE m.pdm_pd = t.x_id2
                                 AND history_status = 'A'
                                 AND pdm_is_actual = 'T'
                                 AND m.pdm_pay_tp = 'BANK' ) > 0
                   THEN '1'
                   ELSE ''
                   END*/
                   ''          AS x_imp_pr_num
              FROM tmp_work_set2 t JOIN accrual ac ON ac.ac_id = t.x_id4
             WHERE t.x_string1 IN ('I', 'U');


        UPDATE accrual a
           SET a.ac_st = 'R'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2 t
                         WHERE t.x_id4 = a.ac_id)
               AND a.ac_st != 'R';

        --После вставки - вызвать API$ACCRUAL.actuilize_payed_sum
        DELETE FROM tmp_work_ids1
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids1
            SELECT x_id4
              FROM tmp_work_set2
             WHERE x_string1 IN ('I', 'U');

        API$ACCRUAL.actuilize_payed_sum (1);

        /*
        INSERT INTO ac_detail (acd_id, acd_ac, acd_op, acd_npt,
                                   acd_start_dt, acd_stop_dt,
                                   acd_sum, acd_month_sum, acd_delta_recalc, acd_delta_pay,
                                   acd_pd, acd_ac_start_dt, acd_ac_stop_dt,
                                   acd_st, history_status)

        где acd_ac найти или создать: по текущему розрах.периоду соотвествующего pa_org
        acd_op = 1
        acd_npt = новое из pdp_npt
        acd_ac_start_dt, acd_ac_stop_dt по acd_ac
        После вставки - вызвать API$ACCRUAL.actuilize_payed_sum
              */
        --останній шаг - закриємо записи.
        UPDATE me_vppun_result_rows r
           SET r.mvsr_st = 'V',
               r.mvsr_pd_pay =
                   (SELECT x_id2
                      FROM tmp_work_set2
                     WHERE x_id5 = r.mvsr_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id5 = r.mvsr_id AND x_string1 IN ('I', 'U'));
    END;

    --==========================================================--
    PROCEDURE Processing_vppun_pay_metod (p_me_id NUMBER, p_hs_id NUMBER)
    IS
        --    l_nst NUMBER := 1101;
        --    l_npt NUMBER := 853;
        l_cnt    NUMBER;
        l_dt     DATE := TO_DATE ('01.07.2024', 'dd.mm.yyyy');
        --    l_hs  NUMBER;
        --l_lock_init TOOLS.t_lockhandler;
        l_lock   TOOLS.t_lockhandler;
        l_num    pc_account.pa_num%TYPE;
    BEGIN
        -- Сформуємо буфер
        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id5,
                                   x_dt1,
                                   x_dt2)
            SELECT                                                --s.mvrr_pd,
                   COALESCE (
                       (SELECT MAX (pd_id)
                          FROM pc_decision pd
                         WHERE     pd.pd_pc = s.mvrr_pc
                               AND pd.pd_nst = 248
                               AND pd.pd_st = 'S'),
                       (SELECT MAX (pd_id)
                          FROM pc_decision pd
                         WHERE     pd.pd_pc = s.mvrr_pc
                               AND pd.pd_nst = 248
                               AND pd.pd_st = 'PS'),
                       s.mvrr_pd)                 AS base_pd_id,
                   (SELECT MAX (pd_id)
                      FROM pc_decision pd
                     WHERE     pd.pd_src_id = s.mvrr_pd
                           AND pd.pd_nst = 1101
                           AND pd.pd_st = 'S')    AS pd_id,
                   r.mvsr_id,
                   l_dt                           AS x_start_dt,
                   LAST_DAY (l_dt)                AS x_stop_dt
              FROM me_vppun_result_rows  r
                   JOIN me_vppun_request_rows s
                       ON s.mvrr_me = r.mvsr_me AND s.mvrr_id = r.mvsr_mvrr
                   JOIN mass_exchanges me ON me.me_id = s.mvrr_me
                   LEFT JOIN pc_decision pd
                       ON     pd.pd_src_id = s.mvrr_pd
                          AND pd.pd_nst = 1101
                          AND pd.pd_st = 'S'
             WHERE     r.mvsr_st = 'W'
                   AND r.mvsr_payment = 0
                   AND s.mvrr_me = p_me_id;

        --AND s.mvrr_me = 702;

        DELETE FROM tmp_work_set2
              WHERE x_id2 IS NULL;

        UPDATE tmp_work_set2
           SET x_id4 =
                   (SELECT MAX (pdm_id)
                      FROM pd_pay_method
                     WHERE     pdm_pd = x_id1
                           AND history_status = 'A'
                           AND pdm_is_actual = 'T');

        --SELECT t.x_id1 AS pd_base, t.x_id2 AS pd_1101, x_id4 AS pdm_base, x_dt1 AS x_start_dt, x_dt2 AS x_stop_dt FROM tmp_work_set2 t;

        UPDATE pd_pay_method m
           SET m.history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE m.pdm_pd = x_id2)
               AND m.history_status = 'A'
               AND m.pdm_start_dt > = TO_DATE ('01.07.2024', 'dd.mm.yyyy');

        UPDATE pd_pay_method m
           SET m.pdm_is_actual = 'F'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE m.pdm_pd = x_id2)
               AND m.history_status = 'A'
               AND m.pdm_is_actual = 'T';


        INSERT INTO pd_pay_method (pdm_id,
                                   pdm_pd,
                                   pdm_start_dt,
                                   pdm_stop_dt,
                                   history_status,
                                   pdm_ap_src,
                                   pdm_pay_tp,
                                   pdm_index,
                                   pdm_kaot,
                                   pdm_street,
                                   pdm_ns,
                                   pdm_building,
                                   pdm_block,
                                   pdm_apartment,
                                   pdm_nb,
                                   pdm_account,
                                   pdm_nd,
                                   pdm_pay_dt,
                                   pdm_hs,
                                   pdm_scc,
                                   pdm_is_actual,
                                   pdm_nd_num)
            SELECT 0       AS x_pdm_id,
                   t.x_pd_1101,
                   t.x_start_dt,
                   t.x_stop_dt,
                   history_status,
                   pdm_ap_src,
                   pdm_pay_tp,
                   pdm_index,
                   pdm_kaot,
                   pdm_street,
                   pdm_ns,
                   pdm_building,
                   pdm_block,
                   pdm_apartment,
                   pdm_nb,
                   pdm_account,
                   pdm_nd,
                   pdm_pay_dt,
                   pdm_hs,
                   pdm_scc,
                   'T'     AS x_pdm_is_actual,
                   pdm_nd_num
              FROM pd_pay_method  m
                   JOIN
                   (SELECT x_id2     AS x_pd_1101,
                           x_id4     AS pdm_base,
                           x_dt1     AS x_start_dt,
                           x_dt2     AS x_stop_dt
                      FROM tmp_work_set2) t
                       ON pdm_id = t.pdm_base;

        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            WITH
                tmp_pdap
                AS
                    (SELECT x_id2     AS x_pd_new,
                            x_dt1     AS x_start_dt,
                            x_dt2     AS x_stop_dt
                       FROM tmp_work_set2)
            SELECT 0     AS x_pdap_id,
                   x_pd_new,
                   x_start_dt,
                   x_stop_dt,
                   'A',
                   p_hs_id
              FROM tmp_pdap
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM pd_accrual_period
                         WHERE     pdap_pd = x_pd_new
                               AND history_status = 'A'
                               AND pdap_start_dt = x_start_dt);

        --останній шаг - закриємо записи.
        UPDATE me_vppun_result_rows r
           SET r.mvsr_st = 'P'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id5 = r.mvsr_id);
    END;

    --==========================================================--
    PROCEDURE Create_Income (                --p_rc rc_candidates.rcc_rc%TYPE,
                             p_recalculates   recalculates%ROWTYPE,
                             p_hs             histsession.hs_id%TYPE)
    IS
    BEGIN
        --знаходимо первинні данні (pd_income_session) по доходах
        UPDATE tmp_work_set2 t
           SET t.x_id3 =
                   (SELECT MAX (s.pin_id)
                      FROM pd_income_session s
                     WHERE     s.pin_pd = t.x_id1
                           AND pin_tp = 'FST'
                           AND pin_st = 'F');

        --Розрахунку доходу
        --Видаляємо лог попереднього розрахунку доходу
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM pd_income_detail
                                JOIN pd_income_calc ON pid_pic = pic_id
                                JOIN tmp_work_set2 ON pic_pd = x_id1
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE pin_st = 'E' AND pin_tp = 'RC');

        --Видаляємо детальний розрахунок доходу
        DELETE FROM pd_income_detail
              WHERE pid_pic IN
                        (SELECT pic_id
                           FROM pd_income_calc
                                JOIN tmp_work_set2 ON pic_pd = x_id1
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE pin_st = 'E' AND pin_tp = 'RC');

        --Видаляємо розрахунок доходу
        DELETE FROM pd_income_calc
              WHERE pic_id IN
                        (SELECT pic_id
                           FROM pd_income_calc
                                JOIN tmp_work_set2 ON pic_pd = x_id1
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE pin_st = 'E' AND pin_tp = 'RC');


        --Збираємо первинну інформацію про доходи:
        --Видаляємо дані по декларації
        DELETE FROM pd_income_src
              WHERE     pis_src <> 'HND'
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE pis_pd = x_id1)
                    AND EXISTS
                            (SELECT 1
                               FROM pd_income_session
                              WHERE     pin_id = pis_pin
                                    AND pin_st = 'E'
                                    AND pin_tp = 'RC');

        --Якщо потрібно, стврорюємо сессію
        MERGE INTO pd_income_session
             USING (SELECT pin_id                   AS x_pin_id,
                           pd_id                    AS x_pin_pd,
                           'RC'                     AS x_pin_tp,
                           p_hs                     AS x_pin_hs_ins,
                           pin_st                   AS x_pin_st,
                           p_recalculates.rc_id     AS x_pin_rc
                      FROM pc_decision
                           LEFT JOIN pd_income_session
                               ON     pin_pd = pd_id
                                  AND pin_tp = 'RC'
                                  AND pin_st = 'E'
                     WHERE EXISTS
                               (SELECT 1
                                  FROM tmp_work_set2
                                 WHERE pd_id = x_id1))
                ON (pin_id = x_pin_id)
        WHEN MATCHED
        THEN
            UPDATE SET pin_rc = x_pin_rc
        WHEN NOT MATCHED
        THEN
            INSERT     (pin_id,
                        pin_pd,
                        pin_tp,
                        pin_hs_ins,
                        pin_st,
                        pin_rc)
                VALUES (0,
                        x_pin_pd,
                        x_pin_tp,
                        x_pin_hs_ins,
                        'E',
                        x_pin_rc);

        --знаходимо pd_income_session по нових доходах
        UPDATE tmp_work_set2 t
           SET t.x_id4 =
                   (SELECT MAX (s.pin_id)
                      FROM pd_income_session s
                     WHERE     s.pin_pd = t.x_id1
                           AND pin_tp = 'RC'
                           AND pin_st = 'E');

        UPDATE tmp_work_set2 t
           SET t.x_id5 =
                   (SELECT MAX (Me.Me_id)     AS Me_id
                      FROM Mass_Exchanges  Me  --загальна інформація про обмін
                           JOIN Me_Income_Request_Rows Mirr
                               ON Mirr.Mirr_Me = Me_Id       --Запитувані дані
                           JOIN Me_Income_Request_Src Mirs
                               ON     Mirs.Mirs_Me = Me.Me_Id
                                  AND Mirs.Mirs_Mirr = Mirr.Mirr_Id --Інформація про запит/відповідь
                           JOIN Me_Income_Result_Rows Misr
                               ON     Misr.Misr_Me = Me.Me_Id
                                  AND Misr.Misr_Mirs = Mirs.Mirs_Id --дані-відповідь
                     WHERE     Me.Me_Month = TRUNC (t.x_dt1)
                           AND Mirr.Mirr_Pd = t.x_id1
                           AND Mirr.Mirr_sc = t.x_id2);

        --Вставляємо дані по декларації - для Допомог
        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp,
                                   pis_tax_sum,
                                   pis_use_tp,
                                   pis_pin)
            SELECT 0           AS pis_id,
                   pis_src,
                   pis_tp,
                   pis_edrpou,
                   pis_fact_sum,
                   pis_final_sum,
                   pis_sc,
                   pis_esv_paid,
                   pis_esv_min,
                   pis_start_dt,
                   pis_stop_dt,
                   pis_pd,
                   pis_app,
                   pis_is_use,
                   pis_exch_tp,
                   pis_tax_sum,
                   pis_use_tp,
                   t.x_id4     AS x_pin
              FROM tmp_work_set2 t JOIN pd_income_src ON t.x_id3 = pis_pin
             WHERE t.x_id3 IS NOT NULL AND pis_src = 'APR';

        --Вставляємо дані по декларації - для Допомог
        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp,
                                   pis_tax_sum,
                                   pis_use_tp,
                                   pis_pin)
            SELECT 0,
                   Mirs.Mirs_Src_Tp
                       AS x_src,
                   Misr.Misr_Pfu_Apri_Tp
                       AS x_tp,
                   mirr.mirr_numident
                       AS x_edrpou,
                   Misr.Misr_Pfu_Sum_Payment
                       AS x_sum,
                   Misr.Misr_Pfu_Sum_Payment
                       AS x_final_sum,
                   Mirr.Mirr_sc
                       AS x_sc,
                   Misr.Misr_Pfu_Pay_Insurer,
                   Misr.Misr_Pfu_Pay_Insurer_Ozn,
                   Misr.Misr_Pfu_Month,
                   LAST_DAY (Misr.Misr_Pfu_Month),
                   t.x_id1
                       AS x_pd,
                   --app_id,
                    (SELECT MAX (app.app_id)
                       FROM pc_decision  pd
                            JOIN ap_person app
                                ON     app.app_ap IN
                                           (pd.pd_ap, pd.pd_ap_reason)
                                   AND app.history_status = 'A'
                      WHERE pd.pd_id = t.x_id1 AND app.app_sc = t.x_id2)
                       AS x_app_id,
                   'F',
                   Misr.Misr_Pfu_Symp_Type
                       AS x_exch_tp,
                   0
                       AS x_tax_sum,
                   'STO',
                   t.x_id4
              FROM tmp_work_set2  t
                   JOIN Me_Income_Request_Rows Mirr ON Mirr.Mirr_Me = t.x_id5 --Запитувані дані
                   JOIN Me_Income_Request_Src Mirs
                       ON Mirs.Mirs_Mirr = Mirr.Mirr_Id --Інформація про запит/відповідь
                   JOIN Me_Income_Result_Rows Misr
                       ON Misr.Misr_Mirs = Mirs.Mirs_Id       --дані-відповідь
             WHERE     Mirs.Mirs_Src_Tp = 'PFU'
                   AND Mirr.Mirr_Pd = t.x_id1
                   AND Mirr.Mirr_sc = t.x_id2
                   AND EXISTS
                           (SELECT app.app_id
                              FROM pc_decision  pd
                                   JOIN ap_person app
                                       ON     app.app_ap IN
                                                  (pd.pd_ap, pd.pd_ap_reason)
                                          AND app.history_status = 'A'
                             WHERE     pd.pd_id = t.x_id1
                                   AND app.app_sc = t.x_id2);

        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp,
                                   pis_tax_sum,
                                   pis_use_tp,
                                   pis_pin)
            SELECT 0,
                   Mirs.Mirs_Src_Tp
                       AS x_src,
                   Misr.Misr_Dfs_Apri_Tp
                       AS x_tp,
                   mirr.mirr_numident
                       AS x_edrpou,
                   Misr.Misr_Dfs_Paid
                       AS x_sum,
                     Misr.Misr_Dfs_Paid
                   - CASE
                         WHEN Misr.Misr_Dfs_Exch_Tp = '101'
                         THEN
                             Misr.Misr_Dfs_Tax_Transferred
                         ELSE
                             0
                     END
                       AS x_final_sum,
                   Mirr.Mirr_sc
                       AS x_sc,
                   'F'
                       AS x_esv_paid,
                   'F'
                       AS x_esv_min,
                   Misr.Misr_Dfs_Start_Dt,
                   Misr.Misr_Dfs_Stop_Dt,
                   t.x_id1
                       AS x_pd,
                   --app_id,
                    (SELECT MAX (app.app_id)
                       FROM pc_decision  pd
                            JOIN ap_person app
                                ON     app.app_ap IN
                                           (pd.pd_ap, pd.pd_ap_reason)
                                   AND app.history_status = 'A'
                      WHERE pd.pd_id = t.x_id1 AND app.app_sc = t.x_id2)
                       AS x_app_id,
                   'F',
                   Misr.Misr_Dfs_Exch_Tp
                       AS x_exch_tp,
                   Misr.Misr_Dfs_Tax_Transferred
                       AS x_tax_sum,
                   'STO',
                   t.x_id4
              FROM tmp_work_set2  t
                   JOIN Me_Income_Request_Rows Mirr ON Mirr.Mirr_Me = t.x_id5 --Запитувані дані
                   JOIN Me_Income_Request_Src Mirs
                       ON Mirs.Mirs_Mirr = Mirr.Mirr_Id --Інформація про запит/відповідь
                   JOIN Me_Income_Result_Rows Misr
                       ON Misr.Misr_Mirs = Mirs.Mirs_Id       --дані-відповідь
             WHERE     Mirs.Mirs_Src_Tp = 'DPS'
                   AND Mirr.Mirr_Pd = t.x_id1
                   AND Mirr.Mirr_sc = t.x_id2
                   AND EXISTS
                           (SELECT app.app_id
                              FROM pc_decision  pd
                                   JOIN ap_person app
                                       ON     app.app_ap IN
                                                  (pd.pd_ap, pd.pd_ap_reason)
                                          AND app.history_status = 'A'
                             WHERE     pd.pd_id = t.x_id1
                                   AND app.app_sc = t.x_id2);

        INSERT INTO pd_income_src (pis_id,
                                   pis_src,
                                   pis_tp,
                                   pis_edrpou,
                                   pis_fact_sum,
                                   pis_final_sum,
                                   pis_sc,
                                   pis_esv_paid,
                                   pis_esv_min,
                                   pis_start_dt,
                                   pis_stop_dt,
                                   pis_pd,
                                   pis_app,
                                   pis_is_use,
                                   pis_exch_tp,
                                   pis_tax_sum,
                                   pis_use_tp,
                                   pis_pin)
            WITH
                periods
                AS
                    (    SELECT LEVEL     AS x_month
                           FROM DUAL
                     CONNECT BY LEVEL < 13),
                mnths
                AS
                    (SELECT ADD_MONTHS (
                                p_recalculates.rc_month,
                                -(  x_month
                                  + API$PC_DECISION.get_month_start (
                                        p_recalculates.rc_month,
                                        nic_1month_alg)))    AS x_months
                       FROM periods, uss_ndi.V_NDI_NST_INCOME_CONFIG
                      WHERE nic_nst = 664 AND x_month <= nic_months)
                SELECT 0,
                       c.nitc_src
                           AS x_src,
                       c.nitc_apri_tp
                           AS x_tp,
                       i.sil_numident
                           AS x_edrpou,
                       i.sil_sum
                           AS x_sum,
                       i.sil_sum
                           AS x_final_sum,
                       i.sil_sc
                           AS x_sc,
                       'F'
                           AS x_esv_paid,
                       'F'
                           AS x_esv_min,
                       TRUNC (i.sil_pay_dt, 'MM'),
                       LAST_DAY (i.sil_pay_dt),
                       t.x_pd,
                       (SELECT MAX (app.app_id)
                          FROM pc_decision  pd
                               JOIN ap_person app
                                   ON     app.app_ap IN
                                              (pd.pd_ap, pd.pd_ap_reason)
                                      AND app.history_status = 'A'
                         WHERE pd.pd_id = t.x_pd AND app.app_sc = t.x_sc)
                           AS x_app_id,
                       'F',
                       i.sil_inc
                           AS x_exch_tp,
                       0
                           AS x_tax_sum,
                       'STO',
                       t.x_pin
                  FROM (SELECT x_id1     AS x_pd,
                               x_id2     AS x_sc,
                               x_id4     AS x_pin,
                               x_dt1     AS x_month_dt
                          FROM tmp_work_set2) t
                       JOIN uss_person.v_sc_income_link i
                           ON i.sil_sc = t.x_sc AND i.sil_st = 'A'
                       JOIN uss_ndi.v_ndi_income_tp_config c
                           ON     i.sil_inc = c.nitc_exch_tp
                              AND c.nitc_src = 'EISSS'
                              AND c.history_status = 'A'
                       JOIN mnths ON x_months = i.sil_pay_dt
                UNION ALL
                SELECT 0,
                       c.nitc_src
                           AS x_src,
                       c.nitc_apri_tp
                           AS x_tp,
                       ''
                           AS x_edrpou,
                       d.acd_sum
                           AS x_sum,
                       d.acd_sum
                           AS x_final_sum,
                       t.x_sc
                           AS x_sc,
                       'F'
                           AS x_esv_paid,
                       'F'
                           AS x_esv_min,
                       d.acd_start_dt,
                       d.acd_stop_dt,
                       t.x_pd,
                       (SELECT MAX (app.app_id)
                          FROM pc_decision  pd
                               JOIN ap_person app
                                   ON     app.app_ap IN
                                              (pd.pd_ap, pd.pd_ap_reason)
                                      AND app.history_status = 'A'
                         WHERE pd.pd_id = t.x_pd AND app.app_sc = t.x_sc)
                           AS x_app_id,
                       'F',
                       p.npt_id
                           AS x_exch_tp,
                       0
                           AS x_tax_sum,
                       'STO',
                       t.x_pin
                  FROM (SELECT x_id1     AS x_pd,
                               x_id2     AS x_sc,
                               x_id4     AS x_pin,
                               x_dt1     AS x_month_dt
                          FROM tmp_work_set2) t
                       JOIN personalcase pc ON pc.pc_sc = t.x_sc
                       JOIN pc_decision pd ON pc.pc_id = pd.pd_pc
                       JOIN ac_detail d
                           ON d.acd_pd = pd.pd_id AND d.acd_prsd IS NOT NULL
                       JOIN uss_ndi.v_ndi_op o
                           ON o.op_id = d.acd_op AND o.op_tp1 = 'NR'
                       JOIN uss_ndi.v_ndi_payment_type p
                           ON p.npt_id = d.acd_npt AND p.history_status = 'A'
                       JOIN uss_ndi.v_ndi_income_tp_config c
                           ON     d.acd_npt = c.nitc_exch_tp
                              AND c.nitc_src = 'EISSS.NPT'
                              AND c.history_status = 'A'
                       JOIN mnths ON x_months = d.acd_start_dt;
    /*
    SELECT 0, c.nitc_src AS x_src,  c.nitc_apri_tp AS x_tp,  '' AS x_edrpou,
           d.acd_sum AS x_sum, d.acd_sum AS x_final_sum,
           t.x_sc AS x_sc,
           'F' AS x_esv_paid,
           'F' AS x_esv_min,
           d.acd_start_dt,
           d.acd_stop_dt,
           t.x_pd,
           ( SELECT MAX(app.app_id)
             FROM pc_decision pd
               JOIN ap_person app ON app.app_ap IN (pd.pd_ap, pd.pd_ap_reason) AND app.history_status = 'A'
             WHERE pd.pd_id = t.x_pd
               AND app.app_sc = t.x_sc
           ) AS x_app_id,
           'F', p.npt_id  AS x_exch_tp, 0 AS x_tax_sum, 'STO',
           t.x_pin
    FROM (SELECT x_id1 AS x_pd, x_id2 AS x_sc, x_id4 AS x_pin, x_dt1 AS x_month_dt FROM tmp_work_set2) t
      JOIN ac_detail d ON d.acd_pd = t.x_pd AND d.acd_prsd IS NOT NULL
      JOIN pc_decision pd ON pd.pd_id = t.x_pd
      JOIN personalcase pc ON pc.pc_id = pd.pd_pc AND pc.pc_sc = t.x_sc
      JOIN uss_ndi.v_ndi_op o ON o.op_id = d.acd_op AND o.op_tp1 = 'NR'
      JOIN uss_ndi.v_ndi_payment_type p ON p.npt_id = d.acd_npt AND p.history_status = 'A'
      JOIN uss_ndi.v_ndi_income_tp_config c ON d.acd_npt  = c.nitc_exch_tp AND c.nitc_src = 'EISSS.NPT' AND c.history_status = 'A'
      JOIN mnths ON x_months = d.acd_start_dt
    ;*/

    END;

    --==========================================================--
    PROCEDURE Processing_Income (p_rc   rc_candidates.rcc_rc%TYPE,
                                 p_hs   histsession.hs_id%TYPE)
    IS
        l_recalculates   recalculates%ROWTYPE;
        MSG_CUR          SYS_REFCURSOR;
    BEGIN
        SELECT *
          INTO l_recalculates
          FROM recalculates
         WHERE rc_id = p_rc;

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1, x_id2, x_dt1)
            WITH
                pd
                AS
                    (SELECT DISTINCT pd_id, f.pdf_sc AS x_sc
                       FROM rc_candidates  c
                            JOIN pc_decision ON pd_id = rcc_pd
                            JOIN pd_family f
                                ON     pdf_pd = pd_id
                                   AND pdf_sc = c.rcc_sc
                                   AND f.history_status = 'A'
                      WHERE rcc_rc = p_rc AND pd_st = 'S' AND pd_nst = 664)
            SELECT pd_id, x_sc, l_recalculates.rc_month
              FROM pd;

        API$PC_DECISION_EXT.Create_Income (l_recalculates, p_hs);

        DELETE FROM tmp_work_ids;

        INSERT INTO tmp_work_ids (x_id)
            SELECT DISTINCT x_id1
              FROM tmp_work_set2
             WHERE x_id4 IS NOT NULL;

        api$calc_income.calc_income_for_pd (2,
                                            NULL,
                                            0,
                                            MSG_CUR);
    /*
        FOR cur IN (SELECT x_id1  FROM tmp_work_set2  WHERE x_id4 IS NOT NULL) LOOP
          api$calc_income.calc_income_for_pd(1, cur.x_id1, 0, MSG_CUR);
        END LOOP;
    */
    --API$Calc_Income.test(NULL, 1);

    END;
--==========================================================--
BEGIN
    -- Initialization
    NULL;
END API$PC_DECISION_EXT;
/