/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET_RPT
IS
    -- Author  : LEVCHENKO
    -- Created : 18.06.2021 13:39:29
    -- Purpose : Звіти

    -- info:   Ініціалізація процесу підготовки звіту "Розписка про отримання особою документів/довідок від працівника ПФУ;"
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #69659
    PROCEDURE reg_receip_info_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL);
END;
/


GRANT EXECUTE ON USS_VISIT.DNET_RPT TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET_RPT TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 6:00:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET_RPT
IS
    -- Author  : LEVCHENKO
    -- Created : 18.06.2021 13:39:29
    -- Purpose : Звіти

    -- info:   Ініціалізація процесу підготовки звіту "Розписка про отримання особою документів/довідок від працівника ПФУ;"
    -- params: p_ap_id - ідентифікатор звернення
    -- note:   #69659
    PROCEDURE reg_receip_info_get (p_ap_id    IN     appeal.ap_id%TYPE,
                                   p_jbr_id      OUT DECIMAL)
    IS
        v_rt_id   rpt_templates.rt_id%TYPE;
    BEGIN
        SELECT rt_id
          INTO v_rt_id
          FROM v_rpt_templates
         WHERE rt_code = 'RECEIPT_INFO_GET_R1';

        p_jbr_id := rdm$rtfl.initreport (v_rt_id);

        --ініціалізація параметрів звіту
        FOR data_cur
            IN (  SELECT (   INITCAP (p.app_ln)
                          || ' '
                          || INITCAP (p.app_fn)
                          || ' '
                          || INITCAP (p.app_mn))                 AS app_pers_name,
                         p.app_inn,
                         (SELECT dt.ndt_name
                            FROM uss_ndi.v_ndi_document_type dt
                           WHERE dt.ndt_id = p.app_ndt)          AS app_ndt_name,
                         p.app_doc_num,
                         a.ap_reg_dt,
                         (SELECT o.org_name
                            FROM v_opfu o
                           WHERE o.org_id = tools.getcurrorg)    AS app_doc_org
                    FROM v_appeal a
                         LEFT JOIN v_ap_person p
                             ON     p.app_ap = a.ap_id
                                AND p.history_status = 'A'
                                AND p.app_tp IN ('P', 'Z') --"Представник заявника", "Заявник" - при наявності в звіт потрапляє представник
                   WHERE a.ap_id = p_ap_id
                ORDER BY p.app_tp)
        LOOP
            rdm$rtfl.addparam (p_jbr_id,
                               'app_pers_name',
                               data_cur.app_pers_name);                  --ПІБ
            rdm$rtfl.addparam (p_jbr_id, 'app_inn', data_cur.app_inn); --РНОКПП, який зазначено в полі РНОКПП в блоці «Учасники звернення»
            rdm$rtfl.addparam (p_jbr_id,
                               'app_ndt_name',
                               data_cur.app_ndt_name); --тип документу -  відповідає назві типу документу із блоку «Документи» (назва може дорівнювати однаму із значень назв «Довідка ОК-2», «Довідка ОК-5», «Довідка ОК-7»…)
            rdm$rtfl.addparam (p_jbr_id, 'app_doc_num', data_cur.app_doc_num); --серія номер – відповідає серії і номеру із блоку «Учасники звернення»
            rdm$rtfl.addparam (
                p_jbr_id,
                'ap_reg_dt',
                TO_CHAR (data_cur.ap_reg_dt, 'DD.MM.YYYY HH24:MI:SS')); --дата звернення
            rdm$rtfl.addparam (p_jbr_id, 'app_doc_org', data_cur.app_doc_org); --орган/організація, у якому/якій видається довідка
            EXIT;
        END LOOP;

        rdm$rtfl.addparam (p_jbr_id,
                           'curr_dt',
                           TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')); --системна дата (поточна)

        rdm$rtfl.adddataset (
            p_jbr_id,
            'main_ds',
               q'[SELECT row_number() over(ORDER BY s.aps_nst, s.aps_id) AS rn, t.nst_name AS aps_name, 1 AS copies_cnt
  FROM uss_visit.v_ap_service s
  JOIN uss_ndi.v_ndi_service_type t ON s.aps_nst = t.nst_id
 WHERE s.aps_ap = ]'
            || TO_CHAR (p_ap_id)
            || q'[
   AND s.history_status = 'A'
   /*AND s.aps_st = 'G'*/]'); --!!! тимчасово в таблицю повинні потрапляти всі послуги в незалежності від статусу

        rdm$rtfl.putreporttoworkingqueue (p_jbr_id);

        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => 'DNET_RPT.REG_RECEIP_INFO_GET',
            action_name   => 'p_ap_id=' || TO_CHAR (p_ap_id));
    END;
END;
/