/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACT_NDZR
IS
    -- Author  : VANO
    -- Created : 20.12.2024 14:09:45
    -- Purpose : Функції маніпуляцій з направленнями на виробництво ДЗР

    PROCEDURE process_act_ndzr_by_appeals;

    PROCEDURE Save_Wares (
        p_Atw_Id              IN OUT At_Wares.Atw_Id%TYPE,
        p_Atw_At              IN     At_Wares.Atw_At%TYPE DEFAULT NULL,
        p_Atw_Wrn             IN     At_Wares.Atw_Wrn%TYPE DEFAULT NULL,
        p_Atw_Ext_Ident       IN     At_Wares.Atw_Ext_Ident%TYPE DEFAULT NULL,
        p_Atw_St              IN     At_Wares.Atw_St%TYPE DEFAULT NULL,
        p_Atw_Issue_Dt        IN     At_Wares.Atw_Issue_Dt%TYPE DEFAULT NULL,
        p_Atw_End_Exp_Dt      IN     At_Wares.Atw_End_Exp_Dt%TYPE DEFAULT NULL,
        p_Atw_Ref_Num         IN     At_Wares.Atw_Ref_Num%TYPE DEFAULT NULL,
        p_Atw_Ref_Dt          IN     At_Wares.Atw_Ref_Dt%TYPE DEFAULT NULL,
        p_Atw_Ref_Exp_Dt      IN     At_Wares.Atw_Ref_Exp_Dt%TYPE DEFAULT NULL,
        p_Atw_Reject_Reason   IN     At_Wares.Atw_Reject_Reason%TYPE DEFAULT NULL);

    PROCEDURE Write_Atw_Log (p_Atwl_Atw       IN Atw_Log.Atwl_Atw%TYPE,
                             p_Atwl_Hs        IN Atw_Log.Atwl_Hs%TYPE,
                             p_Atwl_St        IN Atw_Log.Atwl_St%TYPE,
                             p_Atwl_Message   IN Atw_Log.Atwl_Message%TYPE,
                             p_Atwl_St_Old    IN Atw_Log.Atwl_St_Old%TYPE,
                             p_Atwl_Tp        IN Atw_Log.Atwl_Tp%TYPE);
END API$ACT_NDZR;
/


/* Formatted on 8/12/2025 5:48:38 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACT_NDZR
IS
    PROCEDURE process_act_ndzr_by_appeals
    IS
        l_cnt      NUMBER (10);
        l_hs       histsession.hs_id%TYPE := NULL;
        l_rbm_hs   NUMBER;
        l_lock     TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'PROCESS_ACT_NDZR_BY_APPEALS',
                p_error_msg   =>
                    'В даний момент вже виконується реєстрація направлень!');

        --Вибираємо список раніше не оброблюваних зверненнь
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE     ap_tp = 'DD'
                   AND ap_st = 'O'
                   AND ap_src IN (                                /*'DIIA', */
                                  'PORTAL', 'USS')
                   AND EXISTS
                           (SELECT 1
                              FROM ap_service aps
                             WHERE     aps_ap = ap_id
                                   AND aps.history_status = 'A'
                                   AND aps_nst = 22)
                   AND NOT EXISTS
                           (SELECT 1
                              FROM act
                             WHERE at_ap = ap_id)
                   AND EXISTS
                           (SELECT 1
                              FROM ap_person         app,
                                   ap_document       apd,
                                   ap_document_attr  apda
                             WHERE     app_ap = ap_id
                                   AND app.history_status = 'A'
                                   AND apd_app = app_id
                                   AND apd_ap = ap_id
                                   AND apd.history_status = 'A'
                                   AND apda_apd = apd_id
                                   AND apda_ap = ap_id
                                   AND apda.history_status = 'A'
                                   AND apda_nda IN (8642, 8735)
                                   AND apda_val_string IS NOT NULL
                                   AND REGEXP_LIKE (apda_val_string,
                                                    '^[0-9]+(,[0-9]+)*$'));

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            DELETE FROM tmp_work_set3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set3 (x_id1,
                                       x_string1,
                                       x_string2,
                                       x_id2)
                SELECT x_id,
                       x_tp,
                       ids.COLUMN_VALUE,
                       x_sc
                  FROM (SELECT x_id,
                               CASE
                                   WHEN x_8642_list IS NOT NULL THEN '1'
                                   WHEN x_8735_list IS NOT NULL THEN '2'
                                   ELSE '3'
                               END                               AS x_tp,
                               NVL (x_8642_list, x_8735_list)    AS x_list,
                               x_sc
                          FROM (  SELECT x_id,
                                         MAX (
                                             CASE
                                                 WHEN apda_nda = 8642
                                                 THEN
                                                     apda_val_string
                                             END)        AS x_8642_list,
                                         MAX (
                                             CASE
                                                 WHEN apda_nda = 8735
                                                 THEN
                                                     apda_val_string
                                             END)        AS x_8735_list,
                                         MAX (app_sc)    AS x_sc
                                    FROM tmp_work_ids,
                                         ap_person       app,
                                         ap_document     apd,
                                         ap_document_attr apda
                                   WHERE     app_ap = x_id
                                         AND app.history_status = 'A'
                                         AND apd_app = app_id
                                         AND apd_ap = x_id
                                         AND apd.history_status = 'A'
                                         AND apda_apd = apd_id
                                         AND apda_ap = x_id
                                         AND apda.history_status = 'A'
                                         AND apda_nda IN (8642, 8735)
                                         AND apda_val_string IS NOT NULL
                                         AND REGEXP_LIKE (apda_val_string,
                                                          '^[0-9]+(,[0-9]+)*$')
                                GROUP BY x_id)),
                       TABLE (TOOLS.split_str (x_list, ','))  ids;

            --Не введено ні ДЗР, ні рекомендацій
            DELETE FROM tmp_work_ids
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM tmp_work_set3
                              WHERE x_id = x_id1 AND x_string1 IN ('1', '2'));

            --Неіснуючі записи довідника ДЗР
            DELETE FROM tmp_work_ids
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM tmp_work_set3
                                  WHERE x_id = x_id1 AND x_string1 = '1')
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM uss_ndi.v_ndi_cbi_wares,
                                        tmp_work_set3
                                  WHERE     x_id = x_id1
                                        AND wrn_id = TO_NUMBER (x_string2)
                                        AND x_string1 = '1'
                                        AND wrn_st = 'A');

            --Неіснуючі рекомендації
            DELETE FROM tmp_work_ids
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM tmp_work_set3
                                  WHERE x_id = x_id1 AND x_string1 = '2')
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM uss_person.v_sc_dzr_recomm,
                                        tmp_work_set3
                                  WHERE     x_id = x_id1
                                        AND scdr_id = TO_NUMBER (x_string2)
                                        AND x_string1 = '2'
                                        AND history_Status = 'A');

            --Рекомендації не свого СРКО  (!!! Потрібно буде переписувати, коли з'являться представники тощо)
            DELETE FROM tmp_work_ids
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM tmp_work_set3
                                  WHERE x_id = x_id1 AND x_string1 = '2')
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM uss_person.v_sc_dzr_recomm,
                                        tmp_work_set3
                                  WHERE     x_id = x_id1
                                        AND scdr_id = TO_NUMBER (x_string2)
                                        AND x_string1 = '2'
                                        AND scdr_sc = x_id2
                                        AND history_Status = 'A');

            --Створюємо направлення
            INSERT INTO act (at_tp,
                             at_pc,
                             at_num,
                             at_dt,
                             at_org,
                             at_sc,
                             at_st,
                             at_src,
                             at_wu,
                             at_cu,
                             at_ext_ident,
                             at_ap)
                SELECT 'NDZR',
                       ap_pc,
                       ap_num,
                       ap_reg_dt,
                       ap_dest_org,
                       (SELECT MIN (app_sc)
                          FROM ap_person app
                         WHERE app_ap = ap_id AND app.history_status = 'A'),
                       'R',
                       ap_src,
                       com_wu,
                       ap_cu,
                       ap_ext_ident,
                       ap_id
                  FROM tmp_work_ids, appeal
                 WHERE x_id = ap_id;

            --Якщо в зверненні по послузі з Ід=22 наявний документ з Ід=10351 "Документ, що підтверджує потребу в забезпеченні засобами реабілітації, які видано МСЕК, ВЛК чи ЛКК ",
            --то перевіряти чи ДЗРи, які зазначені в атрибуті з Ід=8642 документа з Ід=10344 "Заява про забезпечення засобом реабілітації (ДЗР)"
            --наявні в атрибуті з Ід=8676 документа з Ід=10351 документа (в цих документах в атрибутах з Ід=8642 та Ід=8676 може міститися по кілька ДЗРів через крапку з комою).
            --Якщо наявні, то заповнювати таблицю AT_WARES наявними ДЗРами..

            --Створюємо рядки ДЗН для направлення
            /*
                  INSERT INTO at_wares (atw_at, atw_wrn, atw_st, history_status)
                    WITH attr_8642 AS
                        ( SELECT at_id, apda_val_string
                          FROM tmp_work_ids
                            JOIN act ON at_ap = x_id
                            JOIN ap_person app   ON app_ap = x_id AND app.history_status = 'A'
                            JOIN ap_document apd ON apd_ap = x_id AND apd_app = app_id AND apd.history_status = 'A'
                            JOIN ap_document_attr apda ON apda_ap = x_id AND apda_apd = apd_id AND apda.history_status = 'A'
                          WHERE apda_nda = 8642
                        ),
                        attr_8676 AS
                        ( SELECT at_id, apda_val_string
                          FROM tmp_work_ids
                            JOIN act ON at_ap = x_id
                            JOIN ap_person app   ON app_ap = x_id AND app.history_status = 'A'
                            JOIN ap_document apd ON apd_ap = x_id AND apd_app = app_id AND apd.history_status = 'A'
                            JOIN ap_document_attr apda ON apda_ap = x_id AND apda_apd = apd_id AND apda.history_status = 'A'
                          WHERE apda_nda = 8676
                        )
                    SELECT attr_8642.at_id, ids.column_value AS x_wrn, 'ZA', 'A'
                    FROM attr_8642,
                         TABLE(TOOLS.split_str(attr_8642.apda_val_string, ',')) ids
                    WHERE NOT EXISTS (SELECT 1 FROM attr_8676 WHERE attr_8642.at_id = attr_8676.at_id)
                    ---------
                    UNION ALL
                    SELECT attr_1.at_id, attr_1.x_wrn, 'ZA', 'A'
                    FROM ( SELECT attr_8642.at_id, ids.column_value AS x_wrn
                           FROM attr_8642,
                                TABLE(TOOLS.split_str(attr_8642.apda_val_string, ',')) ids
                         ) attr_1,
                         ( SELECT attr_8676.at_id, ids.column_value AS x_wrn
                           FROM attr_8676,
                                TABLE(TOOLS.split_str(attr_8676.apda_val_string, ',')) ids
                         ) attr_2
                    WHERE attr_1.at_id = attr_2.at_id
                      AND attr_1.x_wrn = attr_2.x_wrn
                  ;
            */

            --З атрибутів 8642 дістаємо WRN_ID, а з атрибутів 8735 дістаємо SCDR_ID і записуємо у відповідні полня
            --Якщо у зверненні заповнені обидва поля - то пріорітет у 8642
            /*INSERT INTO at_wares (atw_at, atw_wrn, atw_st, history_status, atw_scdr)
              SELECT at_id, CASE x_tp WHEN '1' THEN to_number(ids.column_value)
                                      WHEN '2' THEN (SELECT scdr_wrn FROM uss_person.v_sc_dzr_recomm WHERE scdr_id = to_number(ids.column_value))
                            END AS x_wrn,
                            'ZA', 'A',
                            CASE x_tp --WHEN '1' THEN NULL
                                      WHEN '2' THEN ids.column_value
                            END AS x_scdr
              FROM (SELECT at_id, CASE WHEN x_8642_list IS NOT NULL THEN '1'
                                       WHEN x_8735_list IS NOT NULL THEN '2'
                                       ELSE '3'
                                  END AS x_tp,
                                  NVL(x_8642_list, x_8735_list) AS x_list
                   FROM (SELECT at_id,
                                MAX(CASE WHEN apda_nda = 8642 THEN apda_val_string END) AS x_8642_list,
                                MAX(CASE WHEN apda_nda = 8735 THEN apda_val_string END) AS x_8735_list
                         FROM tmp_work_ids, ap_person app, ap_document apd, ap_document_attr apda, act
                         WHERE app_ap = x_id
                           AND app.history_status = 'A'
                           AND apd_app = app_id
                           AND apd_ap = x_id
                           AND apd.history_status = 'A'
                           AND apda_apd = apd_id
                           AND apda_ap = x_id
                           AND apda.history_status = 'A'
                           AND apda_nda IN (8642, 8735)
                           AND at_ap = x_id
                           AND apda_val_string IS NOT NULL
                           AND REGEXP_LIKE(apda_val_string, '^[0-9]+(,[0-9]+)*$')
                         GROUP BY at_id)), TABLE(TOOLS.split_str(x_list, ',')) ids
              WHERE x_tp IN ('1', '2');*/
            INSERT INTO at_wares (atw_at,
                                  atw_wrn,
                                  atw_st,
                                  history_status,
                                  atw_scdr)
                SELECT at_id,
                       CASE x_tp
                           WHEN '1'
                           THEN
                               TO_NUMBER (x_list_value)
                           WHEN '2'
                           THEN
                               (SELECT scdr_wrn
                                  FROM uss_person.v_sc_dzr_recomm
                                 WHERE scdr_id = TO_NUMBER (x_list_value))
                       END                                         AS x_wrn,
                       'ZA',
                       'A',
                       CASE x_tp                          --WHEN '1' THEN NULL
                                 WHEN '2' THEN x_list_value END    AS x_scdr
                  FROM (SELECT at_id,
                               x_string1     AS x_tp,
                               x_string2     AS x_list_value
                          FROM tmp_work_set3, act
                         WHERE at_ap = x_id1 AND x_string1 IN ('1', '2'));

            --Пишемо в журнал подію створення направлення
            l_hs := TOOLS.GetHistSessionEX (l_hs);
            l_rbm_hs := ikis_rbm.tools.GetHistSession;

            FOR xx IN (SELECT x_id, at_id
                         FROM tmp_work_ids, act
                        WHERE at_ap = x_id)
            LOOP
                api$act.write_at_log (xx.at_id,
                                      l_hs,
                                      'ZA',
                                      CHR (38) || '362',
                                      NULL);
                --реєструємо запит на передачу заяви в ЦБІ
                dnet$exch_cbi.Reg_Get_Wares_Need_Request (
                    p_At_Id    => xx.at_id,
                    p_Rbm_Hs   => l_rbm_hs);
                --Копіюємо документи в СРКО
                api$appeal.Copy_Document2Socialcard (xx.x_id, 1);
            END LOOP;
        END IF;

        DBMS_OUTPUT.put_line (
               'Оброблено '
            || l_cnt
            || ' зверненнь з послугою "Заява про забезпечення допоміжним засобом реабілітації"');

        TOOLS.release_lock (l_lock);
    END;

    PROCEDURE Save_Wares (
        p_Atw_Id              IN OUT At_Wares.Atw_Id%TYPE,
        p_Atw_At              IN     At_Wares.Atw_At%TYPE DEFAULT NULL,
        p_Atw_Wrn             IN     At_Wares.Atw_Wrn%TYPE DEFAULT NULL,
        p_Atw_Ext_Ident       IN     At_Wares.Atw_Ext_Ident%TYPE DEFAULT NULL,
        p_Atw_St              IN     At_Wares.Atw_St%TYPE DEFAULT NULL,
        p_Atw_Issue_Dt        IN     At_Wares.Atw_Issue_Dt%TYPE DEFAULT NULL,
        p_Atw_End_Exp_Dt      IN     At_Wares.Atw_End_Exp_Dt%TYPE DEFAULT NULL,
        p_Atw_Ref_Num         IN     At_Wares.Atw_Ref_Num%TYPE DEFAULT NULL,
        p_Atw_Ref_Dt          IN     At_Wares.Atw_Ref_Dt%TYPE DEFAULT NULL,
        p_Atw_Ref_Exp_Dt      IN     At_Wares.Atw_Ref_Exp_Dt%TYPE DEFAULT NULL,
        p_Atw_Reject_Reason   IN     At_Wares.Atw_Reject_Reason%TYPE DEFAULT NULL)
    IS
    BEGIN
        IF NVL (p_Atw_Id, 0) = 0
        THEN
            INSERT INTO At_Wares (Atw_Id,
                                  Atw_At,
                                  Atw_Wrn,
                                  Atw_St,
                                  History_Status,
                                  Atw_Issue_Dt,
                                  Atw_End_Exp_Dt,
                                  Atw_Ext_Ident,
                                  Atw_Ref_Num,
                                  Atw_Ref_Dt,
                                  Atw_Ref_Exp_Dt,
                                  Atw_Reject_Reason)
                 VALUES (0,
                         p_Atw_At,
                         p_Atw_Wrn,
                         p_Atw_St,
                         'A',
                         p_Atw_Issue_Dt,
                         p_Atw_End_Exp_Dt,
                         p_Atw_Ext_Ident,
                         p_Atw_Ref_Num,
                         p_Atw_Ref_Dt,
                         p_Atw_Ref_Exp_Dt,
                         p_Atw_Reject_Reason)
              RETURNING Atw_Id
                   INTO p_Atw_Id;
        ELSE
            UPDATE At_Wares w
               SET w.Atw_St = p_Atw_St,
                   w.Atw_Issue_Dt = NVL (p_Atw_Issue_Dt, w.Atw_Issue_Dt),
                   w.Atw_End_Exp_Dt =
                       NVL (p_Atw_End_Exp_Dt, w.Atw_End_Exp_Dt),
                   w.Atw_Ref_Num = NVL (p_Atw_Ref_Num, w.Atw_Ref_Num),
                   w.Atw_Ref_Dt = NVL (p_Atw_Ref_Dt, w.Atw_Ref_Dt),
                   w.Atw_Ref_Exp_Dt =
                       NVL (p_Atw_Ref_Exp_Dt, w.Atw_Ref_Exp_Dt),
                   w.Atw_Reject_Reason =
                       NVL (p_Atw_Reject_Reason, w.Atw_Reject_Reason)
             WHERE w.Atw_Id = p_Atw_Id;
        END IF;
    END;

    PROCEDURE Write_Atw_Log (p_Atwl_Atw       IN Atw_Log.Atwl_Atw%TYPE,
                             p_Atwl_Hs        IN Atw_Log.Atwl_Hs%TYPE,
                             p_Atwl_St        IN Atw_Log.Atwl_St%TYPE,
                             p_Atwl_Message   IN Atw_Log.Atwl_Message%TYPE,
                             p_Atwl_St_Old    IN Atw_Log.Atwl_St_Old%TYPE,
                             p_Atwl_Tp        IN Atw_Log.Atwl_Tp%TYPE)
    IS
    BEGIN
        INSERT INTO Atw_Log (Atwl_Id,
                             Atwl_Atw,
                             Atwl_Hs,
                             Atwl_St,
                             Atwl_Message,
                             Atwl_St_Old,
                             Atwl_Tp)
             VALUES (0,
                     p_Atwl_Atw,
                     p_Atwl_Hs,
                     p_Atwl_St,
                     p_Atwl_Message,
                     p_Atwl_St_Old,
                     p_Atwl_Tp);
    END;
BEGIN
    -- Initialization
    NULL;
END API$ACT_NDZR;
/