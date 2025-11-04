/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.CMES$SOCIALCARD
    ACCESSIBLE BY (USS_ESR.CMES$SOCIALCARD)
IS
    -- Author  : SHOSTAK
    -- Created : 01.08.2023 6:26:59 PM
    -- Purpose :

    PROCEDURE Get_Person_Info (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Change_Log (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Address (p_Sc_Id    IN     NUMBER,
                           p_Sca_Tp   IN     VARCHAR2,
                           p_Res         OUT SYS_REFCURSOR);

    PROCEDURE Get_Disability_Info (p_Sc_Id   IN     NUMBER,
                                   p_Res        OUT SYS_REFCURSOR);

    PROCEDURE Get_Features (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Benefits (p_Sc_Id          IN     NUMBER,
                            p_Own_Benefits   IN     VARCHAR2,
                            p_Res               OUT SYS_REFCURSOR);

    PROCEDURE Get_Documents (p_Sc_Id   IN     NUMBER,
                             p_Docs       OUT SYS_REFCURSOR,
                             p_Attrs      OUT SYS_REFCURSOR,
                             p_Files      OUT SYS_REFCURSOR);

    PROCEDURE Clear_Tmp_Ids;

    -- #92370
    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Medical_Info (p_Sc_Id          IN     NUMBER,
                                p_Medical_Data      OUT SYS_REFCURSOR);

    PROCEDURE get_about_me_disability (p_sc_id   IN     NUMBER,
                                       p_res        OUT SYS_REFCURSOR);

    PROCEDURE get_about_me_pension (p_sc_id   IN     NUMBER,
                                    p_res        OUT SYS_REFCURSOR);

    PROCEDURE get_about_me_benefic_category (p_sc_id   IN     NUMBER,
                                             p_res        OUT SYS_REFCURSOR);

    PROCEDURE get_about_me_document (p_sc_id   IN     NUMBER,
                                     p_res        OUT SYS_REFCURSOR);

    PROCEDURE get_about_moz_state_data (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR);

    PROCEDURE get_about_moz_dzr_recomm (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR);
END Cmes$socialcard;
/


GRANT EXECUTE ON USS_PERSON.CMES$SOCIALCARD TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.CMES$SOCIALCARD TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.CMES$SOCIALCARD TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.CMES$SOCIALCARD TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.CMES$SOCIALCARD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.CMES$SOCIALCARD
IS
    PROCEDURE Get_Person_Info (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF p_Sc_Id IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids;

            INSERT INTO tmp_work_ids t (x_id)
                 VALUES (p_Sc_Id);
        END IF;

        OPEN p_Res FOR
            WITH
                Pasp
                AS
                    (SELECT /*+ materialize*/
                            Scd.*
                       FROM (SELECT ROW_NUMBER ()
                                        OVER (
                                            ORDER BY
                                                DECODE (Ndt.Ndt_Uniq_Group,
                                                        'PASP', 1,
                                                        'BRCR', 2,
                                                        'OVRP', 3,
                                                        9),
                                                Ndt.Ndt_Sc_Upd_Priority)
                                        AS Rn,
                                    Scd.*
                               FROM Tmp_Work_Ids  t
                                    JOIN Sc_Document Scd
                                        ON t.x_Id = Scd.Scd_Sc
                                    JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                                        ON     Ndt.Ndt_Id = Scd.Scd_Ndt
                                           AND Ndt.Ndt_Ndc = 13
                              WHERE Scd.Scd_St = '1') Scd
                      WHERE Scd.Rn = 1)
            SELECT c.Sc_Id,
                   --Реєстраційний номер соціальної картки
                   c.Sc_Unique,
                   --Джерело
                   c.Sc_Src,
                   s.Dic_Name
                       AS Sc_Src_Name,
                   --Дата створення соціальної картки
                   c.Sc_Create_Dt,
                   --ПІБ
                   i.Sci_Ln
                       AS Sc_Ln,
                   i.Sci_Fn
                       AS Sc_Fn,
                   i.Sci_Mn
                       AS Sc_Mn,
                   --Дата закриття соціальної картки
                   --todo: уточнити
                   CASE WHEN c.Sc_St = '2' THEN CAST (NULL AS DATE) END
                       Sc_Close_Dt,
                   --Дата народження
                    (SELECT b.Scb_Dt
                       FROM Sc_Birth b
                      WHERE b.Scb_Id = Cc.Scc_Scb)
                       AS Sc_Birth_Dt,
                   --Ознака відмови від РНОКПП
                    (SELECT DECODE (COUNT (*), 0, 'F', 'T')
                       FROM Sc_Document d
                      WHERE     d.Scd_Sc = c.Sc_Id
                            AND d.Scd_Ndt = 10117
                            AND d.Scd_St = '1')
                       AS Sc_Numident_Refuse,
                   --РНОКПП
                    (SELECT d.Scd_Number
                       FROM Sc_Document d
                      WHERE     d.Scd_Sc = c.Sc_Id
                            AND d.Scd_Ndt = 5
                            AND d.Scd_St = '1')
                       AS Sc_Numident,
                   --Тип документу, що посвідчує особу
                   (SELECT Scd_Ndt FROM Pasp)
                       AS Sc_Doc_Ndt,
                   --Серія та номер документу, що посвідчує особу
                   (SELECT Scd_Seria || Scd_Number FROM Pasp)
                       AS Sc_Doc_Num,
                   --Ким видано документ, що посвідчує особу
                   (SELECT Scd_Issued_Who FROM Pasp)
                       AS Sc_Doc_Issuer,
                   --Коли виданий, документ, що посвідчує особу
                   (SELECT Scd_Issued_Dt FROM Pasp)
                       AS Sc_Doc_Issued_Dt,
                   --Дата закінчення строку дії документу, документ, що посвідчує особу
                   (SELECT Scd_Stop_Dt FROM Pasp)
                       AS Sc_Doc_Stop_Dt,
                   --Унікальний номер запису в Єдиному державному демографічному реєстрі
                    (SELECT Uss_Doc.Api$documents.Get_Attr_Val_Str (810,
                                                                    Scd_Dh)
                       FROM Pasp
                      WHERE Scd_Ndt = 7)
                       AS Sc_Doc_Eddr_Num,
                   --Стать
                    (SELECT g.Dic_Name
                       FROM Uss_Ndi.v_Ddn_Gender g
                      WHERE g.Dic_Value = i.Sci_Gender)
                       AS Sc_Gender,
                   --Громадянство
                    (SELECT n.Dic_Name
                       FROM Uss_Ndi.v_Ddn_Nationality n
                      WHERE n.Dic_Value = i.Sci_Nationality)
                       AS Sc_Nationality,
                   --Дата смерті
                    (SELECT Dt.Sch_Dt
                       FROM Sc_Death Dt
                      WHERE Dt.Sch_Id = Cc.Scc_Sch AND Dt.Sch_Is_Dead = 'T')
                       AS Sc_Death_Dt,
                   --Телефон мобільний
                    (SELECT Ct.Sct_Phone_Mob
                       FROM Sc_Contact Ct
                      WHERE Ct.Sct_Id = Cc.Scc_Sct)
                       AS Sc_Phone_Mob,
                   --Телефон стаціонарний
                    (SELECT Ct.Sct_Phone_Mob
                       FROM Sc_Contact Ct
                      WHERE Ct.Sct_Id = Cc.Scc_Sct)
                       AS Sc_Phone,
                   --email
                    (SELECT Ct.Sct_Email
                       FROM Sc_Contact Ct
                      WHERE Ct.Sct_Id = Cc.Scc_Sct)
                       AS Sc_Email,
                   --Статус соціальної картки
                   c.Sc_St,
                   St.Dic_Name
                       AS Sc_St_Name
              FROM Socialcard  c
                   JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Sc_Identity i ON Cc.Scc_Sci = i.Sci_Id
                   JOIN Uss_Ndi.v_Ddn_Source s ON c.Sc_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Sc_St St ON c.Sc_St = St.Dic_Value
             WHERE c.Sc_Id IN (SELECT p_Sc_Id FROM DUAL
                               UNION ALL
                               SELECT t.x_Id
                                 FROM Uss_Person.Tmp_Work_Ids t);
    END;

    PROCEDURE Get_Change_Log (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT c.Scc_Id,
                     --Дата збереження зрізу СРКО
                     c.Scc_Create_Dt,
                     --Дата формування даних з джерела надхоження
                     c.Scc_Src_Dt,
                     --Джерело надходження даних
                     c.Scc_Src,
                     s.Dic_Name     AS Scc_Src_Name
                FROM Sc_Change c
                     JOIN Uss_Ndi.v_Ddn_Source s ON c.Scc_Src = s.Dic_Value
               WHERE c.Scc_Sc = p_Sc_Id
            ORDER BY c.Scc_Create_Dt;
    END;

    PROCEDURE Get_Address (p_Sc_Id    IN     NUMBER,
                           p_Sca_Tp   IN     VARCHAR2,
                           p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF p_Sc_Id IS NOT NULL
        THEN
            DELETE FROM Tmp_Work_Ids;
        END IF;

        OPEN p_Res FOR
            SELECT a.Sca_Id,
                   a.Sca_Sc,
                   a.Sca_Kaot,
                   a.Sca_Region,
                   a.Sca_District,
                   a.Sca_City,
                   a.Sca_Street,
                   a.Sca_Building,
                   a.Sca_Block,
                   a.Sca_Apartment,
                   a.sca_postcode
              FROM Sc_Address a
             WHERE     (a.Sca_Sc IN (SELECT p_Sc_Id FROM DUAL
                                     UNION ALL
                                     SELECT t.x_Id
                                       FROM Uss_Person.Tmp_Work_Ids t))
                   AND a.History_Status = 'A'
                   AND a.Sca_Tp = p_Sca_Tp;
    END;

    PROCEDURE Get_Disability_Info (p_Sc_Id   IN     NUMBER,
                                   p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT --Статус інвалідності
                   'T'
                       AS Scy_Is_Disabled,
                   --Група інвалідності
                   d.Scy_Group,
                   --Строк встановлення групи інвалідності
                   d.Scy_Decision_Dt,
                   d.Scy_Till_Dt,
                   --Дієздатність
                   Uss_Doc.Api$documents.Get_Attr_Val_Str (3703, d.Scy_Dh)
                       AS Scy_Status_Capacity,
                   --Причина інвалідності
                   d.Scy_Reason
              FROM Sc_Disability d
             WHERE d.Scy_Sc = p_Sc_Id AND d.History_Status = 'A';
    END;

    PROCEDURE Get_Features (p_Sc_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR SELECT f.*
                         FROM Sc_Feature f
                        WHERE f.Scf_Sc = p_Sc_Id;
    END;

    PROCEDURE Get_Benefits (p_Sc_Id          IN     NUMBER,
                            p_Own_Benefits   IN     VARCHAR2,
                            p_Res               OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
              SELECT c.Scbc_Nbc,
                     n.Nbc_Name     AS Scbc_Nbc_Name,
                     c.Scbc_Start_Dt,
                     c.Scbc_Stop_Dt
                FROM Sc_Benefit_Category c
                     JOIN Uss_Ndi.v_Ndi_Benefit_Category n
                         ON c.Scbc_Nbc = n.Nbc_Id
               WHERE     c.Scbc_Sc = p_Sc_Id
                     AND c.Scbc_St = 'A'
                     AND (   p_Own_Benefits = 'T'
                          OR Nbc_Id NOT IN (1,
                                            2,
                                            3,
                                            4,
                                            11,
                                            12,
                                            13,
                                            22,
                                            23,
                                            58,
                                            80,
                                            85,
                                            86,
                                            87,
                                            88,
                                            136,
                                            137,
                                            138,
                                            139))
            ORDER BY c.Scbc_Start_Dt DESC;
    END;

    PROCEDURE Get_Documents (p_Sc_Id   IN     NUMBER,
                             p_Docs       OUT SYS_REFCURSOR,
                             p_Attrs      OUT SYS_REFCURSOR,
                             p_Files      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Docs FOR
            SELECT d.Scd_Id,
                   d.Scd_Seria || d.Scd_Number,
                   d.Scd_Ndt,
                   t.Ndt_Name_Short     AS Scd_Ndt_Name,
                   d.Scd_Doc,
                   d.Scd_Dh
              FROM Sc_Document  d
                   JOIN Uss_Ndi.v_Ndi_Document_Type t ON d.Scd_Ndt = t.Ndt_Id
             WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_St = '1';

        OPEN p_Attrs FOR
            SELECT a.*,
                   d.Scd_Id,
                   d.Scd_Doc        AS Doc_Id,
                   d.Scd_Dh         AS Dh_Id,
                   Nda.Nda_Id,
                   Nda.Nda_Name     AS Da_Nda_Name,
                   Nda.Nda_Is_Key,
                   Nda.Nda_Ndt,
                   Nda.Nda_Order,
                   Nda.Nda_Pt,
                   Nda.Nda_Is_Req,
                   Nda.Nda_Def_Value,
                   Nda.Nda_Can_Edit,
                   Nda.Nda_Need_Show,
                   Pt.Pt_Id,
                   Pt.Pt_Code,
                   Pt.Pt_Name,
                   Pt.Pt_Ndc,
                   Pt.Pt_Edit_Type,
                   Pt.Pt_Data_Type
              FROM Sc_Document  d
                   JOIN Uss_Doc.v_Doc_Attr2hist h ON d.Scd_Dh = h.Da2h_Dh
                   JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
                   JOIN Uss_Ndi.v_Ndi_Document_Attr nda
                       ON a.Da_Nda = nda.Nda_Id
                   JOIN Uss_Ndi.v_Ndi_Param_Type Pt ON Pt.Pt_Id = nda.Nda_Pt
             WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_St = '1';

        OPEN p_Files FOR
            SELECT d.Scd_Id,
                   d.Scd_Doc     AS Doc_Id,
                   d.Scd_Dh      AS Dh_Id,
                   f.File_Code,
                   f.File_Name,
                   f.File_Mime_Type,
                   f.File_Size,
                   f.File_Hash,
                   f.File_Create_Dt,
                   f.File_Description
              FROM Sc_Document  d
                   JOIN Uss_Doc.v_Doc_Attachments a ON d.Scd_Dh = a.Dat_Dh
                   JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
             WHERE d.Scd_Sc = p_Sc_Id AND d.Scd_St = '1';
    END;

    PROCEDURE Clear_Tmp_Ids
    IS
    BEGIN
        DELETE FROM Tmp_Work_Ids;
    END;

    -- #92370
    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN LOG_CUR FOR
              SELECT t.scl_id
                         AS log_id,
                     t.scl_sc
                         AS log_obj,
                     t.scl_tp
                         AS log_tp,
                     st.DIC_NAME
                         AS log_st_name,
                     sto.DIC_NAME
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     NVL (tools.GetUserLogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.scl_message)
                         AS log_message
                FROM sc_log t
                     LEFT JOIN uss_ndi.v_ddn_pd_st st
                         ON (st.DIC_VALUE = t.scl_st)
                     LEFT JOIN uss_ndi.v_ddn_pd_st sto
                         ON (sto.DIC_VALUE = t.scl_old_st)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.scl_hs)
               WHERE t.scl_sc = p_Sc_Id
            ORDER BY hs.hs_dt;
    END;

    PROCEDURE Get_Medical_Info (p_Sc_Id          IN     NUMBER,
                                p_Medical_Data      OUT SYS_REFCURSOR)
    IS
    BEGIN
        --#112281
        OPEN p_Medical_Data FOR
            SELECT scd_id,
                   scd_sc,
                   --Джерело
                   source_name,
                   --Серія та номер документу
                   doc_ser_num,
                   --Дата документу
                   doc_dt,
                   --група інвалідності
                   g.DIC_NAME     daisability_group,
                   --Дата встановлення інвалідності
                   daisability_dt
              FROM (  SELECT d.scd_id,
                             d.scd_sc,
                             src.DIC_NAME    source_name,
                             MAX (
                                 CASE
                                     WHEN da.da_nda IN (346)
                                     THEN
                                         da.da_val_string
                                 END)        doc_ser_num,
                             MAX (
                                 CASE
                                     WHEN da.da_nda IN (348) THEN da.da_val_dt
                                 END)        doc_dt,
                             MAX (
                                 CASE
                                     WHEN da.da_nda IN (349)
                                     THEN
                                         da.da_val_string
                                 END)        daisability_group,
                             MAX (
                                 CASE
                                     WHEN da.da_nda IN (352) THEN da.da_val_dt
                                 END)        daisability_dt
                        FROM uss_person.v_sc_document d
                             JOIN uss_doc.v_doc_attr2hist h
                                 ON d.scd_dh = h.da2h_dh
                             JOIN uss_doc.v_doc_attributes da
                                 ON da.da_id = h.da2h_da
                             JOIN uss_ndi.v_ddn_source src
                                 ON d.scd_src = src.DIC_CODE
                       WHERE     d.scd_ndt = 201
                             AND d.scd_sc = p_Sc_Id
                             AND d.scd_st IN ('1', 'A')
                             AND da.da_nda IN (346,
                                               348,
                                               349,
                                               352)
                    GROUP BY d.scd_id, d.scd_sc, src.DIC_NAME)
                   JOIN uss_ndi.v_ddn_scy_group g
                       ON g.DIC_CODE = daisability_group;
    END;

    PROCEDURE get_about_me_disability (p_sc_id   IN     NUMBER,
                                       p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT scy_id,
                   scy_group,
                   g.DIC_NAME     scy_group_name,
                   d.scy_decision_dt,
                   d.scy_till_dt,
                   d.scy_reason,
                   r.DIC_NAME     scy_reason_name,
                   d.scy_start_dt
              FROM SC_DISABILITY  d
                   JOIN SC_FEATURE F ON d.scy_sc = f.scf_sc
                   LEFT JOIN uss_Ndi.v_Ddn_Scy_Group g
                       ON d.scy_group = g.DIC_VALUE
                   LEFT JOIN uss_ndi.v_ddn_inv_reason r
                       ON d.scy_reason = r.DIC_VALUE
             WHERE     scy_sc = p_sc_id
                   AND f.scf_is_dasabled = 'T'
                   AND d.history_status = 'A';
    END;

    PROCEDURE get_about_me_pension (p_sc_id   IN     NUMBER,
                                    p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT p.scp_id,
                   p.scp_is_pension,
                   p.scp_pnf_number,
                   p.scp_pens_tp,
                   tp.DIC_NAME     scp_pens_tp_name,
                   p.scp_begin_dt
              FROM SC_PENSION  P
                   JOIN uss_ndi.v_ddn_scp_pens_tp tp
                       ON p.scp_pens_tp = tp.DIC_VALUE
             WHERE SCP_SC = p_sc_id AND p.scp_is_pension = 'T';
    END;

    PROCEDURE get_about_me_benefic_category (p_sc_id   IN     NUMBER,
                                             p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT a.scbc_id,
                   a.scbc_nbc,
                   bc.nbc_name     scbc_nbc_name,
                   a.scbc_start_dt,
                   a.scbc_stop_dt
              FROM SC_BENEFIT_CATEGORY  a
                   JOIN uss_ndi.v_NDI_BENEFIT_CATEGORY bc
                       ON a.scbc_nbc = bc.nbc_id
             WHERE a.scbc_sc = p_sc_id;
    END;

    PROCEDURE get_about_me_document (p_sc_id   IN     NUMBER,
                                     p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT a.scd_id,
                   a.scd_number,
                   a.scd_issued_dt,
                   a.scd_issued_who,
                   a.scd_start_dt,
                   a.scd_stop_dt,
                   a.scd_ndt,
                   ndt.ndt_name     scd_ndt_name
              FROM sc_document  a
                   JOIN uss_ndi.v_ndi_document_type ndt
                       ON a.scd_ndt = ndt.ndt_id
             WHERE     a.scd_sc = p_sc_id
                   AND ndt.ndt_ndc != 13
                   AND ndt.ndt_id NOT IN (5, 10117)
                   AND a.scd_st = '1';
    END;

    PROCEDURE get_about_moz_state_data (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT SC_ID,
                   scmz_id,
                   scmz_scdi,
                   scmz_org_name,
                   scmz_org_id,
                   scmz_address,
                   scma_id,
                   scma_scdi,
                   scma_decision_num,
                   scma_decision_dt,
                   scma_is_group,
                   scma_start_dt,
                   scma_group,
                   scma_main_diagnosis,
                   scma_is_endless,
                   scma_end_dt,
                   scma_reasons,
                   dr.DIC_NAME      scma_reasons_name,
                   scma_is_prev,
                   scma_is_loss_prof_ability,
                   scma_disease_dt,
                   scma_loss_prof_ability_dt,
                   scma_loss_prof_ability_perc,
                   scma_loss_prof_ability_cause,
                   lpa.DIC_NAME     scma_lpac_name,
                   scma_reexam_dt
              FROM (SELECT p_sc_id
                               SC_ID,
                           a.scmz_id,
                           a.scmz_scdi,
                           a.scmz_org_name,
                           a.scmz_org_id,
                              a.scmz_region_name
                           || ' '
                           || a.scmz_district_name
                           || ' '
                           || a.scmz_city_name
                           || ', вул.'
                           || a.scmz_street_name
                           || ', буд.'
                           || a.scmz_building
                               scmz_address,
                           b.scma_id,
                           b.scma_scdi,
                           b.scma_decision_num,
                           b.scma_decision_dt,
                           b.scma_is_group,
                           b.scma_start_dt,
                           b.scma_group,
                           b.scma_main_diagnosis,
                           b.scma_is_endless,
                           b.scma_end_dt,
                           CAST (b.scma_reasons AS VARCHAR2 (4000))
                               scma_reasons,
                           b.scma_is_prev,
                           b.scma_is_loss_prof_ability,
                           b.scma_disease_dt,
                           b.scma_loss_prof_ability_dt,
                           b.scma_loss_prof_ability_perc,
                           b.scma_loss_prof_ability_cause,
                           b.scma_reexam_dt,
                           COUNT (a.scmz_id) OVER ()
                               scmz_amount,
                           COUNT (b.scma_id) OVER ()
                               scma_amount
                      FROM DUAL  d
                           LEFT JOIN sc_moz_zoz a ON a.scmz_sc = p_sc_id
                           LEFT JOIN sc_moz_assessment b
                               ON b.scma_sc = p_sc_id) d
                   LEFT JOIN uss_ndi.V_DDN_INV_REASON dr
                       ON d.scma_reasons = dr.DIC_VALUE
                   LEFT JOIN uss_ndi.V_DDN_SCMA_LPAC lpa
                       ON d.scma_loss_prof_ability_cause = lpa.DIC_VALUE
             WHERE scmz_amount + scma_amount > 0;
    END;

    PROCEDURE get_about_moz_dzr_recomm (p_sc_id   IN     NUMBER,
                                        p_res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT scmd_id,
                   scmd_scdi,
                   scmd_is_dzr_needed,
                   scmd_iso_code,
                   scmd_dzr_code,
                   scmd_dzr_name,
                   cb.wrn_shifr
              FROM sc_moz_dzr_recomm  a
                   LEFT JOIN uss_ndi.v_ndi_cbi_wares cb
                       ON a.scmd_wrn = cb.wrn_id
             WHERE a.scmd_sc = p_sc_id;
    END;
END Cmes$socialcard;
/