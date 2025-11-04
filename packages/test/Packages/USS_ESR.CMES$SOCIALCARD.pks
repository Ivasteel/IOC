/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$SOCIALCARD
IS
    -- Author  : SHOSTAK
    -- Created : 05.08.2023 9:59:09 AM
    -- Purpose :

    PROCEDURE Get_Socialcard (p_Sc_Id        IN     NUMBER, --Для ОСП передавати null
                              p_Person          OUT SYS_REFCURSOR,
                              p_Addr_Fact       OUT SYS_REFCURSOR,
                              p_Addr_Reg        OUT SYS_REFCURSOR,
                              p_Change_Log      OUT SYS_REFCURSOR);

    PROCEDURE Get_Assignee_Socialcard (p_Sc_Id       IN     NUMBER, --Для ОСП передавати null
                                       p_Person         OUT SYS_REFCURSOR,
                                       p_Addr_Fact      OUT SYS_REFCURSOR,
                                       p_Addr_Reg       OUT SYS_REFCURSOR);

    PROCEDURE Get_Features (p_Sc_Id        IN     NUMBER, --Для ОСП передавати null
                            p_Features        OUT SYS_REFCURSOR,
                            p_Disability      OUT SYS_REFCURSOR);

    PROCEDURE Get_Benefits_And_Aids (p_Sc_Id      IN     NUMBER, --Для ОСП передавати null
                                     p_Benefits      OUT SYS_REFCURSOR);

    FUNCTION Get_At_File (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Soc_Services (p_Sc_Id              IN     NUMBER, --Для ОСП передавати null
                                p_Cases                 OUT SYS_REFCURSOR, --Випадки?
                                p_Provided_Serices      OUT SYS_REFCURSOR --Облік надання послуг
                                                                         );

    PROCEDURE Get_Documents (p_Sc_Id   IN     NUMBER,
                             p_Docs       OUT SYS_REFCURSOR,
                             p_Attrs      OUT SYS_REFCURSOR,
                             p_Files      OUT SYS_REFCURSOR);

    -- #92370: "Інформація щодо доступу до картки"
    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Medical_Info (p_Sc_Id          IN     NUMBER,
                                p_Medical_Data      OUT SYS_REFCURSOR);

    PROCEDURE Get_moz_about_me_data (
        p_Sc_Id                 IN     NUMBER,
        p_Disability_Data          OUT SYS_REFCURSOR,
        p_Pension_data             OUT SYS_REFCURSOR,
        p_Benefic_Category         OUT SYS_REFCURSOR,
        p_Document                 OUT SYS_REFCURSOR,
        p_Moz_State_Data           OUT SYS_REFCURSOR,
        p_Moz_Dzr_Recomm_Date      OUT SYS_REFCURSOR);

    PROCEDURE Get_moz_about_me_in_dev (p_text OUT VARCHAR2);
END Cmes$socialcard;
/


GRANT EXECUTE ON USS_ESR.CMES$SOCIALCARD TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$SOCIALCARD TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$SOCIALCARD TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$SOCIALCARD TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$SOCIALCARD
IS
    PROCEDURE Check_Sc_Access (p_Sc_Id IN NUMBER)
    IS
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            RETURN;
        END IF;

        --TODO: уточнити критерії парава доступу для НСП
        Raise_Application_Error (
            -20000,
            'Недостатньо прав для перегляду соціальної картки');
    END;

    -------------------------------------------------------------
    -- ОСНОВНІ ДАНІ СРКО
    -------------------------------------------------------------
    PROCEDURE Get_Socialcard (p_Sc_Id        IN     NUMBER, --Для ОСП передавати null
                              p_Person          OUT SYS_REFCURSOR,
                              p_Addr_Fact       OUT SYS_REFCURSOR,
                              p_Addr_Reg        OUT SYS_REFCURSOR,
                              p_Change_Log      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            --Check_Sc_Access(p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        Uss_Person.Cmes$socialcard.Clear_Tmp_Ids;
        Uss_Person.Cmes$socialcard.Get_Person_Info (p_Sc_Id   => l_Sc_Id,
                                                    p_Res     => p_Person);
        Uss_Person.Cmes$socialcard.Get_Address (p_Sc_Id    => l_Sc_Id,
                                                p_Sca_Tp   => '2',
                                                p_Res      => p_Addr_Fact);
        Uss_Person.Cmes$socialcard.Get_Address (p_Sc_Id    => l_Sc_Id,
                                                p_Sca_Tp   => '3',
                                                p_Res      => p_Addr_Reg);
        Uss_Person.Cmes$socialcard.Get_Change_Log (p_Sc_Id   => l_Sc_Id,
                                                   p_Res     => p_Change_Log);
    END;

    -------------------------------------------------------------
    -- ОСНОВНІ ДАНІ СРКО УПОВНОВАЖЕННОЇ ОСОБИ
    -------------------------------------------------------------
    PROCEDURE Get_Assignee_Socialcard (p_Sc_Id       IN     NUMBER, --Для ОСП передавати null
                                       p_Person         OUT SYS_REFCURSOR,
                                       p_Addr_Fact      OUT SYS_REFCURSOR,
                                       p_Addr_Reg       OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            Check_Sc_Access (p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        Uss_Person.Cmes$socialcard.Clear_Tmp_Ids;

        INSERT INTO Uss_Person.Tmp_Work_Ids (x_Id)
            --TODO: уточнити критерії вибірки уповновжених осіб/законих представників
            SELECT DISTINCT a.App_Sc
              FROM Ap_Person  p
                   JOIN Ap_Person a
                       ON     p.App_Ap = a.App_Ap
                          AND a.History_Status = 'A'
                          AND a.App_Tp IN ('OR',
                                           'AF',
                                           'AG',
                                           'P')
             WHERE     p.App_Sc = l_Sc_Id
                   AND p.History_Status = 'A'
                   AND p.App_Tp IN ('Z', 'OS');

        Uss_Person.Cmes$socialcard.Get_Person_Info (p_Sc_Id   => NULL,
                                                    p_Res     => p_Person);
        Uss_Person.Cmes$socialcard.Get_Address (p_Sc_Id    => NULL,
                                                p_Sca_Tp   => '2',
                                                p_Res      => p_Addr_Fact);
        Uss_Person.Cmes$socialcard.Get_Address (p_Sc_Id    => NULL,
                                                p_Sca_Tp   => '3',
                                                p_Res      => p_Addr_Reg);
    END;

    -------------------------------------------------------------
    -- СОЦІАЛЬНІ СТАТУСИ ТА ОСОБЛИВОСТІ
    -------------------------------------------------------------
    PROCEDURE Get_Features (p_Sc_Id        IN     NUMBER, --Для ОСП передавати null
                            p_Features        OUT SYS_REFCURSOR,
                            p_Disability      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            Check_Sc_Access (p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        Uss_Person.Cmes$socialcard.Get_Features (p_Sc_Id   => p_Sc_Id,
                                                 p_Res     => p_Features);
        Uss_Person.Cmes$socialcard.Get_Disability_Info (
            p_Sc_Id   => l_Sc_Id,
            p_Res     => p_Disability);
    END;

    -------------------------------------------------------------
    -- ПІЛЬГИ ТА ДОПОМОГИ
    -------------------------------------------------------------
    PROCEDURE Get_Benefits_And_Aids (p_Sc_Id      IN     NUMBER, --Для ОСП передавати null
                                     p_Benefits      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id          NUMBER;
        l_Own_Benefits   VARCHAR2 (10);
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
            l_Own_Benefits := 'T';
        ELSE
            Check_Sc_Access (p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
            l_Own_Benefits := 'F';
        END IF;

        Uss_Person.Cmes$socialcard.Get_Benefits (
            p_Sc_Id          => l_Sc_Id,
            p_Own_Benefits   => l_Own_Benefits,
            p_Res            => p_Benefits);
    --TODO: зробити вичтку субсидій та допомог(уточнити де брати)
    END;

    FUNCTION Get_At_File (p_At_Id IN NUMBER, p_Ndt_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_File_Code   VARCHAR2 (100);
    BEGIN
        SELECT MAX (f.File_Code)
          INTO l_File_Code
          FROM At_Document  d
               JOIN Uss_Doc.v_Doc_Attachments a ON d.Atd_Dh = a.Dat_Dh
               JOIN Uss_Doc.v_Files f ON a.Dat_File = f.File_Id
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = p_Ndt_Id
               AND d.History_Status = 'A';

        RETURN l_File_Code;
    END;

    -------------------------------------------------------------
    -- СОЦІАЛЬНІ ПОСЛУГИ
    -------------------------------------------------------------
    PROCEDURE Get_Soc_Services (p_Sc_Id              IN     NUMBER, --Для ОСП передавати null
                                p_Cases                 OUT SYS_REFCURSOR, --Випадки?
                                p_Provided_Serices      OUT SYS_REFCURSOR --Облік надання послуг
                                                                         )
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            Check_Sc_Access (p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        OPEN p_Cases FOR
            SELECT --Найменування суб’єкта надання соціальних послуг(Надавач)
                   CASE
                       WHEN r.Rnspm_Tp = 'F'
                       THEN
                              r.Rnsps_Last_Name
                           || ' '
                           || r.Rnsps_First_Name
                           || ' '
                           || r.Rnsps_Middle_Name
                       WHEN r.Rnspm_Tp = 'O'
                       THEN
                           r.Rnsps_Last_Name
                   END
                       AS Rnsp_Name,
                   --ПІБ кейс-менеджера, якого призначено для надання соціальної послуги
                   --TODO: уточнити чи це той саме кейс менеджер якого призначенно для ведення випадку
                   Ikis_Rbm.Tools.Getcupib (Pd.At_Cu)
                       AS Cm_Pib,
                   --Інформація про рішення(Мета залучення КМ)
                   --Номер ріщення
                   Pd.At_Num
                       AS Decision_Num,
                   --Дата затвердження рішення
                    (SELECT MAX (s.Hs_Dt)
                       FROM At_Log l JOIN Histsession s ON l.Atl_Hs = s.Hs_Id
                      WHERE     l.Atl_At = Pd.At_Id
                            AND l.Atl_St IN ('SA', 'O.SA'))
                       AS Decision_Dt,
                   --Посилання на файл друкованої форми рішення
                   COALESCE (Get_At_File (Pd.At_Id, 842),
                             Get_At_File (Pd.At_Id, 850))
                       AS Decision_Form_File,
                   --Інформція про акт первинної оцінки(Мета залучення КМ)
                   --Номер акту
                   Apop.At_Num
                       AS Apop_Num,
                   --Дата завершення оцінки
                   Apop.At_Action_Stop_Dt
                       AS Apop_Dt,
                   --Посилання на файл друкованої форми акту
                   Get_At_File (Pd.At_Id, 804)
                       AS Apop_Form_File
              FROM Act  Pd
                   JOIN Act Apop
                       ON     Pd.At_Ap = Apop.At_Ap
                          --Акти перв. оцінки в статусах "Затверджено" або "Підписано надавачем"
                          AND Apop.At_St IN ('AS', 'AP')
                   JOIN Uss_Rnsp.v_Rnsp r ON Pd.At_Rnspm = r.Rnspm_Id
             WHERE     Pd.At_Sc = l_Sc_Id --todo: уточнити чи потрібно враховувати тип учасника з at_person або підписантів
                   AND Pd.At_Tp = 'PDSP'
                   --Рішення в статусі "Підписано договір"
                   AND Pd.At_St = 'SS';

        --Облік надання послуг
        OPEN p_Provided_Serices FOR
            SELECT --Номер договору
                   Tctr.At_Num                         AS Tctr_Num,
                   --Дата договору
                    (SELECT MAX (s.Hs_Dt)
                       FROM At_Log  l
                            JOIN Histsession s
                                ON l.Atl_Hs = s.Hs_Id
                      WHERE     l.Atl_At = Tctr.At_Id
                            AND l.Atl_St IN ('DT'))    AS Tctr_Dt,
                   --Статус договору
                   Tctr.At_St                          AS Tctr_St,
                   St.Dic_Name                         AS Tctr_St_Name
              --Послуги
              --TODO: уточнити чи потрібно видавати дані в розрізі кожної послуги окремо
              --можливо коли з'явиться індивідуальний план - стане зрозуміліше
              /*(SELECT Listagg(n.Nst_Name, ', ') WITH GROUP(ORDER BY n.Nst_Name)
               FROM At_Service Svc
               JOIN Uss_Ndi.v_Ndi_Service_Type n
                 ON Svc.Ats_Nst = n.Nst_Id
              WHERE Svc.Ats_At = Tctr.At_Id
                AND Svc.History_Status = 'A'
                AND Svc.Ats_St IN ()) AS Services*/
              FROM Act  Tctr
                   JOIN Uss_Ndi.v_Ddn_At_Tctr_St St
                       ON Tctr.At_St = St.Dic_Value
             WHERE     Tctr.At_Sc = l_Sc_Id --todo: уточнити чи потрібно враховувати тип учасника з at_person або підписантів
                   AND Tctr.At_Tp = 'TCTR'
                   AND Tctr.At_St IN ('DT', 'DP');
    END;

    -------------------------------------------------------------
    -- ДОКУМЕНТИ
    -------------------------------------------------------------
    PROCEDURE Get_Documents (p_Sc_Id   IN     NUMBER,
                             p_Docs       OUT SYS_REFCURSOR,
                             p_Attrs      OUT SYS_REFCURSOR,
                             p_Files      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            Check_Sc_Access (p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        Uss_Person.Cmes$socialcard.Get_Documents (p_Sc_Id   => l_Sc_Id,
                                                  p_Docs    => p_Docs,
                                                  p_Attrs   => p_Attrs,
                                                  p_Files   => p_Files);
    END;


    -- #92370: "Інформація щодо доступу до картки"
    PROCEDURE get_sc_log (p_sc_id IN NUMBER, log_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_person.cmes$socialcard.get_sc_log (p_sc_id, log_cur);
    END;

    --112281  Медичні дані
    PROCEDURE Get_Medical_Info (p_Sc_Id          IN     NUMBER,
                                p_Medical_Data      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        IF p_Sc_Id IS NULL
        THEN
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        ELSE
            --Check_Sc_Access(p_Sc_Id);
            l_Sc_Id := p_Sc_Id;
        END IF;

        Tools.LOG (p_src              => 'USS_ESR.Cmes$socialcard.Get_Medical_Info',
                   p_obj_tp           => 'SC',
                   p_obj_id           => l_Sc_Id,
                   p_regular_params   => NULL);
        Uss_Person.Cmes$socialcard.Get_Medical_Info (
            p_Sc_Id          => l_Sc_Id,
            p_Medical_data   => p_Medical_data);
    END;

    PROCEDURE Get_moz_about_me_data (
        p_Sc_Id                 IN     NUMBER,
        p_Disability_Data          OUT SYS_REFCURSOR,
        p_Pension_data             OUT SYS_REFCURSOR,
        p_Benefic_Category         OUT SYS_REFCURSOR,
        p_Document                 OUT SYS_REFCURSOR,
        p_Moz_State_Data           OUT SYS_REFCURSOR,
        p_Moz_Dzr_Recomm_Date      OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);
        --#112913
        Tools.LOG (
            p_src      => 'USS_ESR.Cmes$socialcard.Get_moz_about_me_data',
            p_obj_tp   => 'SC',
            p_obj_id   => l_Sc_Id,
            p_regular_params   =>
                'l_Sc_Id=' || l_Sc_Id || ' p_sc_id=' || p_sc_id);
        Uss_Person.Cmes$socialcard.get_about_me_disability (
            l_Sc_Id,
            p_Disability_Data);

        Uss_Person.Cmes$socialcard.get_about_me_pension (l_Sc_Id,
                                                         p_Pension_data);

        Uss_Person.Cmes$socialcard.get_about_me_benefic_category (
            l_Sc_Id,
            p_Benefic_Category);

        Uss_Person.Cmes$socialcard.get_about_me_document (l_Sc_Id,
                                                          p_Document);

        Uss_Person.Cmes$socialcard.get_about_moz_state_data (
            l_Sc_Id,
            p_Moz_State_Data);

        --Uss_Person.Cmes$socialcard.get_about_moz_dzr_recomm(l_Sc_Id,
        --                                                    p_Moz_Dzr_Recomm_Date);
        /*
        OPEN p_Moz_Dzr_Recomm_Date FOR
         SELECT scmd_id,
               scmd_scdi,
               scmd_is_dzr_needed,
               scmd_iso_code,
               scmd_dzr_code,
               scmd_dzr_name,
               wrn_shifr,
               at_num,
               at_dt,
               at_ap,
               atw_st_name,
               atw_reject_reason,
               atw_issue_dt,
               atw_end_exp_dt,
               atw_ref_num,
               atw_ref_dt,
               atw_ref_exp_dt
         FROM(
         SELECT scdr_id scmd_id,
               null scmd_scdi,
               'T' scmd_is_dzr_needed,
               cb.wrn_shifr scmd_iso_code,
               cb.wrn_code scmd_dzr_code,
               cb.wrn_name scmd_dzr_name,
               cb.wrn_shifr,
               ac.at_num,
               ac.at_dt,
               ac.at_ap,
               d.DIC_NAME atw_st_name,
               atw.atw_reject_reason,
               atw.atw_issue_dt,
               atw.atw_end_exp_dt,
               atw.atw_ref_num,
               atw.atw_ref_dt,
               atw.atw_ref_exp_dt,
               a.scdr_sc,
               nvl(row_number() over (partition by a.scdr_wrn order by at_id desc),1) rnk
            FROM uss_person.v_sc_dzr_recomm a
            LEFT JOIN uss_ndi.v_ndi_cbi_wares cb
               ON a.scdr_wrn = cb.wrn_id
            LEFT JOIN act ac
              ON ac.at_sc = a.scdr_sc
             AND ac.at_tp = 'NDZR'
            LEFT JOIN at_wares atw
              ON ac.at_id = atw.atw_at
             AND atw.history_status='A'
             AND atw_wrn = cb.wrn_id
            LEFT JOIN uss_ndi.V_DDN_ATW_ST d
              ON atw.atw_st = d.DIC_VALUE
          WHERE a.scdr_sc = l_Sc_Id)
          WHERE rnk=1;*/

        OPEN p_Moz_Dzr_Recomm_Date FOR
            WITH
                ActData
                AS
                    (SELECT *
                       FROM (SELECT ac.at_sc,
                                    ac.at_num,
                                    ac.at_dt,
                                    ac.at_ap,
                                    d.DIC_NAME    atw_st_name,
                                    atw.atw_wrn,
                                    atw.atw_reject_reason,
                                    atw.atw_issue_dt,
                                    atw.atw_end_exp_dt,
                                    atw.atw_ref_num,
                                    atw.atw_ref_dt,
                                    atw.atw_ref_exp_dt,
                                    atw.atw_scdr,
                                    NVL (
                                        DENSE_RANK ()
                                            OVER (PARTITION BY atw.atw_scdr
                                                  ORDER BY ac.at_id DESC),
                                        1)        rnk
                               FROM act  ac
                                    JOIN at_wares atw
                                        ON     ac.at_id = atw.atw_at
                                           AND atw.history_status = 'A'
                                    JOIN uss_ndi.V_DDN_ATW_ST d
                                        ON atw.atw_st = d.DIC_VALUE
                              WHERE ac.at_sc = l_Sc_Id AND ac.at_tp = 'NDZR')
                      WHERE rnk = 1)
            SELECT scdr_id          scmd_id,
                   NULL             scmd_scdi,
                   'T'              scmd_is_dzr_needed,
                   cb.wrn_shifr     scmd_iso_code,
                   cb.wrn_code      scmd_dzr_code,
                   cb.wrn_name      scmd_dzr_name,
                   cb.wrn_shifr,
                   at_num,
                   at_dt,
                   at_ap,
                   atw_st_name,
                   atw_reject_reason,
                   atw_issue_dt,
                   atw_end_exp_dt,
                   atw_ref_num,
                   atw_ref_dt,
                   atw_ref_exp_dt,
                   a.scdr_sc
              FROM uss_person.v_sc_dzr_recomm  a
                   JOIN uss_ndi.v_ndi_cbi_wares cb ON a.scdr_wrn = cb.wrn_id
                   LEFT JOIN ActData ad ON a.scdr_id = ad.atw_scdr
             WHERE a.scdr_sc = l_Sc_Id;
    END;

    PROCEDURE Get_moz_about_me_in_dev (p_text OUT VARCHAR2)
    IS
    BEGIN
        p_text := 'Упс... функціонал в процесі розробки';
    END;
END Cmes$socialcard;
/