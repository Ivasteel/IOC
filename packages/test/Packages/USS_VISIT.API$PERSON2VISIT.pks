/* Formatted on 8/12/2025 5:59:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.API$PERSON2VISIT
IS
    -- Author  : OLEKSII
    -- Created : 04.04.2023 13:25:58
    -- Purpose :

    PROCEDURE Event2Appeal;
END API$PERSON2VISIT;
/


GRANT EXECUTE ON USS_VISIT.API$PERSON2VISIT TO II01RC_USS_VISIT_INT
/

GRANT EXECUTE ON USS_VISIT.API$PERSON2VISIT TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.API$PERSON2VISIT TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.API$PERSON2VISIT TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.API$PERSON2VISIT TO USS_RNSP
/


/* Formatted on 8/12/2025 5:59:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.API$PERSON2VISIT
IS
    -- створення дублікату звернення
    PROCEDURE Event2Appeal
    IS
        l_ap_id    NUMBER;
        l_app_id   NUMBER;
        l_ank_id   NUMBER;
        l_apd_id   NUMBER;
        l_ap_st    VARCHAR2 (20);
        l_ap_src   VARCHAR2 (20) := 'DIIA';
    BEGIN
        FOR rec IN (SELECT * FROM tmp_event2appeal)
        LOOP
            --Звернення
            l_ap_st := 'V';
            api$appeal.Save_Appeal (p_Ap_Id          => NULL,
                                    p_Ap_Num         => '',
                                    p_Ap_Reg_Dt      => TRUNC (rec.x_doc_dt),
                                    p_Ap_Create_Dt   => SYSDATE,
                                    p_Ap_Src         => l_Ap_Src,
                                    p_Ap_St          => l_ap_st,
                                    p_Com_Org        => rec.x_com_org,
                                    p_Ap_Is_Second   => 'F',
                                    p_Ap_Vf          => NULL,
                                    p_Com_Wu         => NULL,
                                    p_Ap_Tp          => 'CH_RES',
                                    p_New_Id         => l_ap_id,
                                    p_Ap_Ext_Ident   => rec.x_scde);

            --зберігли id звернення по довідці ВПО
            UPDATE tmp_event2appeal ea
               SET ea.x_ap = l_ap_id
             WHERE ea.x_scde = rec.x_scde;

            dbms_output_put_lines ('l_ap_id = ' || l_ap_id);

            --зальємо персону
            FOR app
                IN (  SELECT sc.sc_id,
                             sc.sc_scc,
                             sc.sc_unique,
                             idn.sci_fn                   AS x_fn,
                             idn.sci_ln                   AS x_ln,
                             idn.sci_mn                   AS x_mn,
                             idn.sci_gender               AS x_gender,
                             (  SELECT d.Scd_Number
                                  FROM Uss_Person.v_Sc_Document d
                                 WHERE     d.Scd_Sc = sc.sc_id
                                       AND d.Scd_St = '1'
                                       AND d.Scd_Ndt = 5
                              ORDER BY d.Scd_Id
                                 FETCH FIRST ROW ONLY)    AS x_Inn
                        FROM uss_person.v_socialcard sc
                             JOIN uss_person.v_sc_change ch
                                 ON ch.scc_sc = sc.sc_id
                             JOIN uss_person.v_sc_identity idn
                                 ON idn.sci_id = ch.scc_sci
                       WHERE sc.sc_id = rec.x_sc
                    ORDER BY ch.scc_create_dt DESC
                       FETCH FIRST ROW ONLY)
            LOOP
                --#APP_NUM
                INSERT INTO Ap_Person (App_Id,
                                       App_Ap,
                                       App_Tp,
                                       App_Inn,
                                       App_Ndt,
                                       App_Doc_Num,
                                       App_Fn,
                                       App_Mn,
                                       App_Ln,
                                       History_Status,
                                       App_Sc,
                                       App_Gender,
                                       App_Esr_Num,
                                       App_Num)
                     VALUES (0,
                             l_ap_id,
                             'Z',
                             App.x_Inn,
                             NULL,
                             NULL,
                             app.x_fn,
                             app.x_mn,
                             app.x_ln,
                             'A',
                             app.sc_id,
                             app.x_gender,
                             app.sc_unique,
                             API$APPEAL.Get_Next_App_Num (l_ap_id))
                  RETURNING App_Id
                       INTO l_app_Id;

                UPDATE Ap_Person p
                   SET (p.app_doc_num, p.app_ndt) =
                           (  SELECT d.Scd_Seria || d.Scd_Number, d.Scd_Ndt
                                FROM Uss_Person.v_Sc_Document d
                                     JOIN Uss_Ndi.v_Ndi_Document_Type t
                                         ON     d.Scd_Ndt = t.Ndt_Id
                                            AND t.Ndt_Ndc = 13
                               WHERE d.Scd_Sc = rec.x_sc AND d.Scd_St = '1'
                            ORDER BY d.Scd_Id
                               FETCH FIRST ROW ONLY)
                 WHERE App_Id = l_app_Id;
            /*
            SELECT d.Scd_Number,
                   d.Scd_Ndt
              FROM Uss_Person.Sc_Document d
             WHERE d.Scd_Sc = p_Sc
                   AND d.Scd_St = '1'
                   AND d.Scd_Ndt = 5
             ORDER BY d.Scd_Id
             FETCH FIRST ROW ONLY
             */

            --dbms_output_put_lines('Ap_Person '||SQL%ROWCOUNT);
            END LOOP;

            INSERT INTO ap_service (aps_id,
                                    aps_nst,
                                    aps_ap,
                                    aps_st,
                                    history_status)
                 VALUES (0,
                         900,
                         l_ap_id,
                         'R',
                         'A');

            --Довідка ВПО
            INSERT INTO ap_document (apd_id,
                                     apd_ap,
                                     apd_app,
                                     apd_ndt,
                                     apd_doc,
                                     apd_dh,
                                     history_status)
                 VALUES (0,
                         l_ap_id,
                         l_app_id,
                         10052,
                         rec.x_doc,
                         rec.x_dh,
                         'A')
              RETURNING apd_id
                   INTO l_apd_Id;

            --dbms_output_put_lines('ap_document '||SQL%ROWCOUNT);
            INSERT INTO ap_document_attr (apda_id,
                                          apda_ap,
                                          apda_apd,
                                          apda_nda,
                                          apda_val_int,
                                          apda_val_dt,
                                          apda_val_string,
                                          apda_val_id,
                                          apda_val_sum,
                                          history_status)
                SELECT 0,
                       l_ap_id,
                       l_apd_id,
                       aa.da_nda,
                       aa.da_val_int,
                       aa.da_val_dt,
                       aa.da_val_string,
                       aa.da_val_id,
                       aa.da_val_sum,
                       'A'
                  FROM Uss_Doc.v_Doc_Attr2hist  hh
                       JOIN Uss_Doc.v_Doc_Attributes aa
                           ON hh.Da2h_Da = aa.Da_Id
                 WHERE hh.da2h_dh = rec.x_dh;

            --dbms_output_put_lines('ap_document_attr '||SQL%ROWCOUNT);

            --Довідка Анкета
            INSERT INTO ap_document (apd_id,
                                     apd_ap,
                                     apd_app,
                                     apd_ndt,             /*apd_doc, apd_dh,*/
                                     history_status)
                 VALUES (0,
                         l_ap_id,
                         l_app_id,
                         605,
                         'A')
              RETURNING apd_id
                   INTO l_ank_id;

            --dbms_output_put_lines('ap_document '||SQL%ROWCOUNT);
            INSERT INTO ap_document_attr (apda_id,
                                          apda_ap,
                                          apda_apd,
                                          apda_nda,
                                          apda_val_int,
                                          apda_val_dt,
                                          apda_val_string,
                                          apda_val_id,
                                          apda_val_sum,
                                          history_status)
                SELECT 0,
                       l_ap_id,
                       l_ank_id,
                       1775,
                       aa.da_val_int,
                       aa.da_val_dt,
                       aa.da_val_string,
                       aa.da_val_id,
                       aa.da_val_sum,
                       'A'
                  FROM Uss_Doc.v_Doc_Attr2hist  hh
                       JOIN Uss_Doc.v_Doc_Attributes aa
                           ON hh.Da2h_Da = aa.Da_Id
                 WHERE hh.da2h_dh = rec.x_dh AND aa.da_nda = 2292;
        --dbms_output_put_lines('ap_document_attr '||SQL%ROWCOUNT);

        END LOOP;

        --перельемо до ЕСР
        INSERT INTO uss_esr.appeal (ap_id,
                                    ap_pc,
                                    ap_tp,
                                    ap_reg_dt,
                                    ap_src,
                                    ap_st,
                                    com_org,
                                    ap_num,
                                    ap_create_dt,
                                    ap_ext_ident)
            SELECT ap_id,
                   ea.x_pc,
                   ap_tp,
                   ap_reg_dt,
                   ap_src,
                   ap_st,
                   com_org,
                   ap_num,
                   ap_create_dt,
                   ap_ext_ident
              FROM tmp_event2appeal  ea
                   JOIN uss_visit.appeal ON ea.x_ap = ap_id;

        --dbms_output_put_lines('uss_esr.appeal '||SQL%ROWCOUNT);

        --#APP_NUM
        INSERT INTO uss_esr.ap_person (app_id,
                                       app_ap,
                                       app_sc,
                                       app_tp,
                                       history_status,
                                       app_scc,
                                       app_num)
            SELECT app_id     AS x_app_id,
                   app_ap     AS x_app_ap,
                   app_sc     AS x_app_sc,
                   app_tp,
                   history_status,
                   sc_scc,
                   app_num
              FROM tmp_event2appeal  ea
                   JOIN ap_person ON app_ap = x_ap
                   LEFT JOIN uss_person.v_socialcard ON sc_id = app_sc;

        --dbms_output_put_lines('uss_esr.appeal '||SQL%ROWCOUNT);

        INSERT INTO uss_esr.ap_service (aps_id,
                                        aps_nst,
                                        aps_ap,
                                        aps_st,
                                        history_status)
            SELECT aps_id,
                   aps_nst,
                   aps_ap,
                   aps_st,
                   history_status
              FROM tmp_event2appeal ea JOIN ap_service ON aps_ap = x_ap;


        INSERT INTO uss_esr.ap_document (apd_id,
                                         apd_ap,
                                         apd_app,
                                         apd_ndt,
                                         apd_doc,
                                         apd_dh,
                                         history_status)
            SELECT apd_id             AS x_apd_id,
                   apd_ap             AS x_apd_ap,
                   apd_app            AS x_apd_app,
                   apd_ndt            AS x_apd_ndt,
                   apd_doc            AS x_apd_doc,
                   apd_dh             AS x_apd_dh,
                   history_status     AS x_history_status
              FROM tmp_event2appeal ea JOIN ap_document ON apd_ap = x_ap;

        --dbms_output_put_lines('uss_esr.ap_document '||SQL%ROWCOUNT);

        INSERT INTO uss_esr.ap_document_attr (apda_id,
                                              apda_ap,
                                              apda_apd,
                                              apda_nda,
                                              apda_val_int,
                                              apda_val_sum,
                                              apda_val_id,
                                              apda_val_dt,
                                              apda_val_string,
                                              history_status)
            SELECT apda_id             AS x_apda_id,
                   apda_ap             AS x_apda_ap,
                   apda_apd            AS x_apda_apd,
                   apda_nda            AS x_apda_nda,
                   apda_val_int        AS x_apda_val_int,
                   apda_val_sum        AS x_apda_val_sum,
                   apda_val_id         AS x_apda_val_id,
                   apda_val_dt         AS x_apda_val_dt,
                   apda_val_string     AS x_apda_val_string,
                   history_status      AS x_history_status
              FROM tmp_event2appeal  ea
                   JOIN ap_document_attr ON apda_ap = x_ap;
    --dbms_output_put_lines('uss_esr.ap_document_attr '||SQL%ROWCOUNT);

    END;
BEGIN
    -- Initialization
    NULL;
END API$PERSON2VISIT;
/