/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ANKETA
IS
    TYPE Type_Rec_Anketa IS RECORD
    (
        --app_id    number(14),
        --app_ap    number(14),
        app_sc                 NUMBER (14),
        pd_id                  NUMBER (14),
        app_tp                 VARCHAR2 (20),
        calc_dt                DATE,
        FamilyConnect          VARCHAR2 (20),      --Ступінь родинного зв’язку
        Adopter                VARCHAR2 (20),                    --Усиновлювач
        Guardian               VARCHAR2 (20),                         --опікун
        Trustee                VARCHAR2 (20),                   --піклувальник
        Еducator              VARCHAR2 (20),                      --Вихователь
        Alone                  VARCHAR2 (20),               --Одинокий/Одинока
        Widow                  VARCHAR2 (20),                  --Вдова/Вдовець
        ChildBornNotUA         VARCHAR2 (20), --Дитина народжена поза межами України
        EducatorFT             VARCHAR2 (20), --"Батько/мати-вихователь дитячого будинку сімейного типу"
        ParentsAdp             VARCHAR2 (20),  --Прийомні батьки (батько/мати)
        TeacherFoster          VARCHAR2 (20),         --Патронатний вихователь
        NotSalary              VARCHAR2 (20), --Перебуває у відпустці без збереження заробітної плати
        Disability             VARCHAR2 (20),           --Особа з інвалідністю
        DisabilityFromChild    VARCHAR2 (20), --Особа з інвалідністю з дитинства
        DisabilityGroup        VARCHAR2 (20),             --Група інвалідності
        DisabilityState        VARCHAR2 (20),            --Статус інвалідності
        DisabilityReason       VARCHAR2 (20),           --причина інвалідності
        DisabilityChildNPP     VARCHAR2 (20), --Дитина з інвалідністю внаслідок аварії на ЧАЕС
        DisabilityChild        VARCHAR2 (20),          --Дитина з інвалідністю
        CarriedPayments        VARCHAR2 (20), --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
        Workable               VARCHAR2 (20),                   --Працездатний
        NotWorkable            VARCHAR2 (20),                --Не працездатний
        NotWorking             VARCHAR2 (20),                      --Не працює
        Working                VARCHAR2 (20),                         --Працює
        Studying               VARCHAR2 (20),                     --Навчається
        Military               VARCHAR2 (20),     --Проходить військову службу
        CaringChildUnder3      VARCHAR2 (20), --Доглядає за дитиною до 3-х років
        CaringChildUnder6      VARCHAR2 (20), --Доглядає за дитиною до 6-х років
        CaringInvUnder18       VARCHAR2 (20), --Доглядає за дитиною інвалідом до 18-х років
        MaternityLeave         VARCHAR2 (20), --Перебуває у відпустці у зв’язку з вагітністю та пологами
        MainTenance            VARCHAR2 (20),   --Знаходиться на держутриманні
        ChildBornOutside       VARCHAR2 (20), --The child was born outside Ukraine
        StudyingForm           VARCHAR2 (20),                 --форма навчання
        BirthDay               DATE,                         --День народження
        AgeYear                NUMBER (10),                              --Вік
        AgeYear_OS             NUMBER (10),                          --Вік ОСП
        Disability_OS          VARCHAR2 (20)        --Особа з інвалідністю ОСП
    );

    TYPE Table_Anketa IS TABLE OF Type_Rec_Anketa;

    g_Anketa        Table_Anketa := Table_Anketa ();

    TYPE Type_Rec_Information IS RECORD
    (
        app_id                 NUMBER (14),
        app_ap                 NUMBER (14),
        app_sc                 NUMBER (14),
        pd_id                  NUMBER (14),
        app_tp                 VARCHAR2 (20),
        DisabilityChild        VARCHAR2 (20),          --Дитина з інвалідністю
        DisabilityFromChild    VARCHAR2 (20), --Особа з інвалідністю з дитинства
        Guardian               VARCHAR2 (20),                         --опікун
        Trustee                VARCHAR2 (20),                   --піклувальник
        Adopter                VARCHAR2 (20),                    --Усиновлювач
        Parents                VARCHAR2 (20),                    --Мати/батько
        RepresentativeInst     VARCHAR2 (20), --Представник закладу, де особа з інвалідністю перебуває на держутриманні
        ParentsEducator        VARCHAR2 (20)      --Один з батьків-вихователів
    );

    TYPE Table_Information IS TABLE OF Type_Rec_Information;

    g_Information   Table_Information := Table_Information ();

    TYPE Type_Rec_Anketa_AT IS RECORD
    (
        AT_ID               NUMBER (14),
        AT_AP               NUMBER (14),
        AT_TP               VARCHAR2 (10),
        AT_ST               VARCHAR2 (10),
        AT_ORG              NUMBER (5),
        AP_TP               VARCHAR2 (10),
        --ATS_NST      number(14),
        CALC_DT             DATE,
        APP_ID              NUMBER (14),
        APP_TP              VARCHAR2 (10),
        APP_SC              NUMBER (14),
        APP_SRC             VARCHAR2 (10),
        MainInitNdt         NUMBER,
        ServiceNeeded       VARCHAR2 (10),
        ServiceTo           VARCHAR2 (10),
        FamilyConnect       VARCHAR2 (10),
        Disability          VARCHAR2 (10),
        DisabilityGroup     VARCHAR2 (10),
        DisabilityState     VARCHAR2 (10),
        DisabilityReason    VARCHAR2 (10),
        NotWorking          VARCHAR2 (10),
        Workable            VARCHAR2 (10),
        NotWorkable         VARCHAR2 (10),
        MainTenance         VARCHAR2 (10),      --Знаходиться на держутриманні
        BirthDay            DATE,                            --День народження
        AgeYear             NUMBER (10),                                 --Вік
        AgeYear_OS          NUMBER (10),                             --Вік ОСП
        Disability_OS       VARCHAR2 (20)           --Особа з інвалідністю ОСП
    );

    TYPE Table_Anketa_AT IS TABLE OF Type_Rec_Anketa_AT;

    g_Anketa_AT     Table_Anketa_AT := Table_Anketa_AT ();

    TYPE Type_Rec_Check_pd_st IS RECORD
    (
        ch_pd_st        VARCHAR2 (20),
        IsAprove        VARCHAR2 (20),
        Aprove_ps_st    VARCHAR2 (20),
        IsReject        VARCHAR2 (20),
        Reject_ps_st    VARCHAR2 (20)
    );

    TYPE Table_Check_pd_st IS TABLE OF Type_Rec_Check_pd_st;

    g_Check_pd_st   Table_Check_pd_st := Table_Check_pd_st ();

    /*
      g_Check_pd_st  Table_Check_pd_st := Table_Check_pd_st(  Type_Rec_Check_pd_st('R0', 'F', '',  'F', ''),
                                                              Type_Rec_Check_pd_st('R1', 'F', '',  'F', ''),
                                                              Type_Rec_Check_pd_st('P',  'T', 'S', 'F', ''),
                                                              Type_Rec_Check_pd_st('K',  'T', 'S', 'T', 'S'),
                                                              Type_Rec_Check_pd_st('S',  'F', '',  'T', 'R,NR')
                                                                   );
    */
    TYPE Type_Rec_Check_ps_st IS RECORD
    (
        ch_ps_st        VARCHAR2 (20),
        IsAprove        VARCHAR2 (20),
        Aprove_pd_st    VARCHAR2 (20),
        IsReject        VARCHAR2 (20),
        Reject_pd_st    VARCHAR2 (20)
    );

    TYPE Table_Check_ps_st IS TABLE OF Type_Rec_Check_ps_st;

    g_Check_ps_st   Table_Check_ps_st := Table_Check_ps_st ();

    /*
      g_Check_ps_st  Table_Check_ps_st := Table_Check_ps_st(  Type_Rec_Check_ps_st('P', 'T', 'P', 'F', ''),
                                                              Type_Rec_Check_ps_st('S', 'T', 'K', 'T', 'K'),
                                                              Type_Rec_Check_ps_st('R', 'F', '',  'T', 'S'),
                                                              Type_Rec_Check_ps_st('NR','F', '',  'T', 'S')
                                                                   );
    */

    TYPE Type_Rec_app_period IS RECORD
    (
        pe_app_tp     VARCHAR2 (20),                       -- ap_person.app_tp
        pe_pd_nst     NUMBER (14),                                          --
        pe_tp         VARCHAR2 (20),                             -- START/STOP
        pe_ndt        NUMBER (14),                                          --
        pe_nda        NUMBER (14),                                          --
        pe_correct    NUMBER (14)                                           --
    );

    TYPE Type_Tbl_app_period IS TABLE OF Type_Rec_app_period;

    g_app_period    Type_Tbl_app_period := Type_Tbl_app_period ();


    PROCEDURE Set_Anketa;

    FUNCTION Get_Anketa
        RETURN Table_Anketa
        PIPELINED;

    FUNCTION Get_Information
        RETURN Table_Information
        PIPELINED;

    PROCEDURE Set_Anketa_AT;

    PROCEDURE Set_Anketa_at_by_id (p_id IN NUMBER);

    FUNCTION Get_Anketa_AT
        RETURN Table_Anketa_AT
        PIPELINED;

    FUNCTION Get_Check_pd_st
        RETURN Table_Check_pd_st
        PIPELINED;

    FUNCTION Get_Check_ps_st
        RETURN Table_Check_ps_st
        PIPELINED;

    --Потім звмінимо на довідник, якщо буде працювати.
    FUNCTION Get_app_period
        RETURN Type_Tbl_app_period
        PIPELINED;

    PROCEDURE Clear_Anketa;
END;
/


/* Formatted on 8/12/2025 5:48:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ANKETA
IS
    PROCEDURE Clear_Anketa
    IS
    BEGIN
        g_Anketa := Table_Anketa ();
    END;

    --========================================
    PROCEDURE Set_Anketa
    IS
    BEGIN
        api$account.init_tmp_for_pd;

        SELECT                                                       --app_id,
                                                                     --app_ap,
             app_sc,
             pd_id,
             app_tp,
             calc_dt,
             NVL ("FamilyConnect", '-')
                 FamilyConnect,                    --Ступінь родинного зв’язку
             NVL ("Adopter", 'F')
                 Adopter,                                        --Усиновлювач
             NVL ("Guardian", 'F')
                 Guardian,                                            --опікун
             NVL ("Trustee", 'F')
                 Trustee,                                       --піклувальник
             NVL ("Еducator", 'F')
                 Еducator,                                         --Вихователь
             NVL ("Alone", 'F')
                 Alone,                                     --Одинокий/Одинока
             NVL ("Widow", 'F')
                 Widow,                                        --Вдова/Вдовець
             NVL ("ChildBornNotUA", 'F')
                 ChildBornNotUA,        --Дитина народжена поза межами України
             NVL ("EducatorFT", 'F')
                 EducatorFT, --"Батько/мати-вихователь дитячого будинку сімейного типу"
             NVL ("ParentsAdp", 'F')
                 ParentsAdp,                   --Прийомні батьки (батько/мати)
             NVL ("TeacherFoster", 'F')
                 TeacherFoster,                       --Патронатний вихователь
             NVL ("NotSalary", 'F')
                 NotSalary, --Перебуває у відпустці без збереження заробітної плати
             NVL ("Disability", 'F')
                 Disability,                            --Особа з інвалідністю
             NVL ("DisabilityFromChild", 'F')
                 DisabilityFromChild,       --Особа з інвалідністю з дитинства
             NVL ("DisabilityGroup", '-')
                 DisabilityGroup,                         --Група інвалідності
             NVL ("DisabilityState", '-')
                 DisabilityState,                        --Статус інвалідності
             NVL ("DisabilityReason", '-')
                 DisabilityReason,                      --причина інвалідності
             NVL ("DisabilityChildNPP", 'F')
                 DisabilityChildNPP, --Дитина з інвалідністю внаслідок аварії на ЧАЕС
             NVL ("DisabilityChild", 'F')
                 DisabilityChild,                     -- Дитина з інвалідністю
             NVL ("CarriedPayments", 'F')
                 CarriedPayments, --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
             NVL ("Workable", 'F')
                 Workable,                                      --Працездатний
             NVL ("NotWorkable", 'F')
                 NotWorkable,                                --Не Працездатний
             NVL ("NotWorking", 'F')
                 NotWorking,                                       --Не працює
             NVL ("Working", 'F')
                 Working,                                             --Працює
             NVL ("Studying", 'F')
                 Studying,                                        --Навчається
             NVL ("Military", 'F')
                 Military,                        --Проходить військову службу
             NVL ("CaringChildUnder3", 'F')
                 CaringChildUnder3,         --Доглядає за дитиною до 3-х років
             NVL ("CaringChildUnder6", 'F')
                 CaringChildUnder6,         --Доглядає за дитиною до 6-х років
             NVL ("CaringInvUnder18", 'F')
                 CaringInvUnder18, --Доглядає за дитиною інвалідом до 18-х років
             NVL ("MaternityLeave", 'F')
                 MaternityLeave, --Перебуває у відпустці у зв’язку з вагітністю та пологами
             NVL ("MainTenance", 'F')
                 MainTenance,                   --Знаходиться на держутриманні
             NVL ("ChildBornOutside", 'F')
                 ChildBornOutside,        --The child was born outside Ukraine
             API$CALC_RIGHT.get_docx_string (pd_id,
                                             app_sc,
                                             98,
                                             690,
                                             calc_dt)
                 StudyingForm,
             birthday,
             --nvl(trunc(months_between (sysdate, birthday )/12,0),-1) AgeYear
             NVL (TRUNC (MONTHS_BETWEEN (calc_dt, birthday) / 12, 0), -1)
                 AgeYear,
             NULL,
             NULL
        BULK COLLECT INTO g_Anketa
        FROM (SELECT                                 --app.tpp_app AS  app_id,
                                                                 --app.app_ap,
                   app.tpp_sc                                             AS app_sc,
                   app.pd_id,
                   app.tpp_app_tp                                         AS app_tp,
                   app.calc_dt,
                   apda.apda_nda,
                   apda.apda_val_string,
                   COALESCE (api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         6,
                                                         606,
                                                         app.calc_dt), --Паспорт
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         7,
                                                         607,
                                                         app.calc_dt), --ID картка
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         37,
                                                         91,
                                                         app.calc_dt), --свідоцтво про народження дитини
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         8,
                                                         2014,
                                                         app.calc_dt),
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         9,
                                                         2015,
                                                         app.calc_dt),
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         11,
                                                         2329,
                                                         app.calc_dt),
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         13,
                                                         2016,
                                                         app.calc_dt),
                             api$calc_right.get_docx_dt (tpp_pd,
                                                         tpp_sc,
                                                         673,
                                                         762,
                                                         app.calc_dt))    birthday
              FROM tmp_work_ids
                   --join  v_ap_person_for_decision app on app.pd_id=x_id
                   JOIN v_tmp_person_for_decision app ON app.pd_id = x_id
                   LEFT JOIN tmp_pa_documents tpd
                       ON     tpd_pd = tpp_pd
                          AND tpd_sc = tpp_sc
                          AND tpd_ndt = 605
                          AND app.calc_dt BETWEEN tpd_dt_from AND tpd_dt_to
                   LEFT JOIN ap_document_attr apda
                       ON     apda.apda_apd = tpd.tpd_apd
                          AND apda.history_status = 'A')
                 PIVOT (
                       MAX (apda_val_string)
                       FOR apda_nda
                       IN (649 "FamilyConnect",    --Ступінь родинного зв’язку
                          644 "Adopter",                         --Усиновлювач
                          642 "Guardian",                             --опікун
                          643 "Trustee",                        --піклувальник
                          648 "Еducator",                          --Вихователь
                          641 "Alone",                      --Одинокий/Одинока
                          674 "Widow",                         --Вдова/Вдовець
                          871 "ChildBornNotUA", --Дитина народжена поза межами України
                          1858 "EducatorFT", --"Батько/мати-вихователь дитячого будинку сімейного типу"
                          2654 "ParentsAdp",   --Прийомні батьки (батько/мати)
                          2668 "TeacherFoster",       --Патронатний вихователь
                          866 "NotSalary", --Перебуває у відпустці без збереження заробітної плати
                          660 "Disability",             --Особа з інвалідністю
                          645 "DisabilityFromChild", --Особа з інвалідністю з дитинства
                          666 "DisabilityGroup",          --Група інвалідності
                          796 "DisabilityState",         --Статус інвалідності
                          795 "DisabilityReason",       --причина інвалідності
                          942 "DisabilityChildNPP", --Дитина з інвалідністю внаслідок аварії на ЧАЕС
                          1797 "DisabilityChild",     -- Дитина з інвалідністю
                          789 "CarriedPayments", --На підопічного здійснюються виплати (аліменти, пенсія, допомога, стипендія)
                          664 "Workable",                       --Працездатний
                          665 "NotWorkable",                 --Не працездатний
                          663 "NotWorking",                        --Не працює
                          650 "Working",                              --Працює
                          662 "Studying",                         --Навчається
                          867 "Military",         --Проходить військову службу
                          653 "CaringChildUnder3", --Доглядає за дитиною до 3-х років
                          654 "CaringChildUnder6", --Доглядає за дитиною до 6-х років
                          659 "CaringInvUnder18", --Доглядає за дитиною інвалідом до 18-х років
                          865 "MaternityLeave", --Перебуває у відпустці у зв’язку з вагітністю та пологами
                          677 "MainTenance",    --Знаходиться на держутриманні
                          871 "ChildBornOutside" --The child was born outside Ukraine
                                                ));
    /*
          SELECT app_id,
                 app_ap,
                 app_sc,
                 pd_id,
                 app_tp,
                 nvl("DisabilityChild",      'F')  DisabilityChild,       -- Дитина з інвалідністю
                 nvl("DisabilityFromChild",  'F')  DisabilityFromChild,   -- Особа з інвалідністю з дитинства
                 nvl("Guardian",             'F')  Guardian,              -- Опікун
                 nvl("Trustee",              'F')  Trustee,               -- Піклувальник
                 nvl("Adopter",              'F')  Adopter,               -- Усиновлювач
                 nvl("Parents",              'F')  Parents,               -- Мати/батько
                 nvl("RepresentativeInst",   'F')  RepresentativeInst,    -- Представник закладу, де особа з інвалідністю перебуває на держутриманні
                 nvl("ParentsEducator",      'F')  ParentsEducator        -- Один з батьків-вихователів
               bulk collect into g_Information
          FROM
          (
            SELECT app.app_id, app.app_ap, app.app_sc, app.pd_id, app.app_tp, apda.apda_nda, apda.apda_val_string
            from tmp_work_ids
                 join  v_ap_person_for_decision app on app.pd_id=x_id
                 join ap_document apd on apd.apd_app=app.app_id and apd.apd_ndt=10037 and apd.history_status='A'
                 left join ap_document_attr apda on apda.apda_apd=apd.apd_id and apda.history_status='A'
          )
          PIVOT
          (
            max(apda_val_string)
            FOR apda_nda IN (  929  "DisabilityChild",       -- Дитина з інвалідністю
                               930  "DisabilityFromChild",   -- Особа з інвалідністю з дитинства
                               914  "Guardian",              -- Опікун
                               915  "Trustee",               -- Піклувальник
                               916  "Adopter",               -- Усиновлювач
                               917  "Parents",               -- Мати/батько
                               918  "RepresentativeInst",    -- Представник закладу, де особа з інвалідністю перебуває на держутриманні
                               919  "ParentsEducator"        -- Один з батьків-вихователів
                             )
          );

        */

    /*
       929 DisabilityChild Дитина з інвалідністю
       930 DisabilityFromChild Особа з інвалідністю з дитинства
       914  Guardian Опікун
       915  Trustee Піклувальник
       916  Adopter Усиновлювач
       917  Parents Мати/батько
       918  RepresentativeInst Представник закладу, де особа з інвалідністю перебуває на держутриманні
       919  ParentsEducator Один з батьків-вихователів

    */

    END;

    --========================================
    FUNCTION Get_Anketa
        RETURN Table_Anketa
        PIPELINED
    IS
    BEGIN
        IF g_Anketa.COUNT > 0
        THEN
            FOR i IN g_Anketa.FIRST .. g_Anketa.LAST
            LOOP
                PIPE ROW (g_Anketa (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================
    FUNCTION Get_Information
        RETURN Table_Information
        PIPELINED
    IS
    BEGIN
        IF g_Information.COUNT > 0
        THEN
            FOR i IN g_Information.FIRST .. g_Information.LAST
            LOOP
                PIPE ROW (g_Information (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    PROCEDURE Set_Anketa_at_by_id (p_id IN NUMBER)
    IS
    BEGIN
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT at_id
              FROM act
             WHERE at_id = p_id;

        Set_Anketa_AT ();
    END;

    --========================================
    PROCEDURE Set_Anketa_AT
    IS
    BEGIN
        SELECT at_id,
               at_ap,
               at_tp,
               at_st,
               at_org,
               ap_tp,
               --ats_nst,
               calc_dt,
               app_id,
               app_tp,
               app_sc,
               ap_src,
               MainInitNdt,
               ServiceNeeded,
               ServiceTo,
               FamilyConnect,
               Disability,
               DisabilityGroup,
               DisabilityState,
               DisabilityReason,
               NotWorking,
               Workable,
               NotWorkable,
               MainTenance,
               birthday,
               NVL (TRUNC (MONTHS_BETWEEN (calc_dt, birthday) / 12, 0), -1)
                   AgeYear,
               MAX (
                   CASE
                       WHEN APP_TP = 'OS'
                       THEN
                           NVL (
                               TRUNC (
                                   MONTHS_BETWEEN (calc_dt, birthday) / 12,
                                   0),
                               -1)
                   END)
                   OVER ()
                   AgeYear_OS,
               MAX (CASE WHEN APP_TP = 'OS' THEN DISABILITY END) OVER ()
                   DISABILITY_OS
          BULK COLLECT INTO g_Anketa_AT
          FROM (SELECT a.at_id,
                       a.at_ap,
                       a.at_tp,
                       a.at_st,
                       a.at_org,
                       ap.ap_tp,
                       --ats.ats_nst,
                       ap.ap_reg_dt
                           AS calc_dt,
                       app.app_id,
                       app.app_tp,
                       app.app_sc,
                       ap.ap_src,
                       Api$appeal.Get_Init_Apd (ap.ap_id, '801')
                           MainInitNdt,
                       API$APPEAL.Get_Ap_Attr_Str (ap.ap_id, 1868)
                           ServiceNeeded,        --Соціальних послуг потребує,
                       API$APPEAL.Get_Ap_Attr_Str (ap.ap_id, 1895)
                           ServiceTo,            --Соціальних послуг потребує,
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  649,
                                                  '-')
                           AS FamilyConnect,       --Ступінь родинного зв’язку
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  660,
                                                  'F')
                           AS Disability,               --Особа з інвалідністю
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  666,
                                                  '-')
                           AS DisabilityGroup,            --Група інвалідності
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  796,
                                                  '-')
                           AS DisabilityState,           --Статус інвалідності
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  795,
                                                  '-')
                           AS DisabilityReason,
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  663,
                                                  'F')
                           AS NotWorking,                          --Не працює
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  664,
                                                  'F')
                           AS Workable,                         --Працездатний
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  665,
                                                  'F')
                           AS NotWorkable,                   --Не працездатний
                       API$APPEAL.Get_Doc_String (app_id,
                                                  605,
                                                  677,
                                                  'F')
                           AS MainTenance,      --Знаходиться на держутриманні
                       COALESCE (API$APPEAL.Get_Doc_dt (app_id, 6, 606), --Паспорт
                                 API$APPEAL.Get_Doc_dt (app_id, 7, 607), --ID картка
                                 API$APPEAL.Get_Doc_dt (app_id, 37, 91), --свідоцтво про народження дитини
                                 API$APPEAL.Get_Doc_dt (app_id, 8, 2014),
                                 API$APPEAL.Get_Doc_dt (app_id, 9, 2015),
                                 API$APPEAL.Get_Doc_dt (app_id, 11, 2329),
                                 API$APPEAL.Get_Doc_dt (app_id, 13, 2016),
                                 API$APPEAL.Get_Doc_dt (app_id, 673, 762))
                           birthday
                  FROM tmp_work_ids
                       JOIN act a ON at_id = x_id
                       --JOIN at_service ats ON ats_at = at_id
                       JOIN appeal ap ON ap_id = at_ap
                       JOIN ap_person app
                           ON app.app_ap = ap_id AND app.history_status = 'A');
    END;

    --========================================
    FUNCTION Get_Anketa_AT
        RETURN Table_Anketa_AT
        PIPELINED
    IS
    BEGIN
        IF g_Anketa_AT.COUNT > 0
        THEN
            FOR i IN g_Anketa_AT.FIRST .. g_Anketa_AT.LAST
            LOOP
                PIPE ROW (g_Anketa_AT (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================
    PROCEDURE Set_Rec_Anketa (p_pd NUMBER, Rec_Anketa OUT Type_Rec_Anketa)
    IS
    BEGIN
        FOR a IN (SELECT *
                    FROM TABLE (API$ANKETA.get_Anketa)
                   WHERE pd_id = p_pd)
        LOOP
            Rec_Anketa := a;
        END LOOP;
    END;

    --========================================
    FUNCTION Get_Check_pd_st
        RETURN Table_Check_pd_st
        PIPELINED
    IS
    BEGIN
        IF g_Check_pd_st.COUNT > 0
        THEN
            FOR i IN g_Check_pd_st.FIRST .. g_Check_pd_st.LAST
            LOOP
                PIPE ROW (g_Check_pd_st (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================
    FUNCTION Get_Check_ps_st
        RETURN Table_Check_ps_st
        PIPELINED
    IS
    BEGIN
        IF g_Check_ps_st.COUNT > 0
        THEN
            FOR i IN g_Check_ps_st.FIRST .. g_Check_ps_st.LAST
            LOOP
                PIPE ROW (g_Check_ps_st (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================
    PROCEDURE set_Rec_Check_pd_st (l_ch_pd_st       VARCHAR2,
                                   l_IsAprove       VARCHAR2,
                                   l_Aprove_ps_st   VARCHAR2,
                                   l_IsReject       VARCHAR2,
                                   l_Reject_ps_st   VARCHAR2)
    IS
        Check_pd_st   Type_Rec_Check_pd_st;
    BEGIN
        g_Check_pd_st.EXTEND;
        Check_pd_st.ch_pd_st := l_ch_pd_st;
        Check_pd_st.IsAprove := l_IsAprove;
        Check_pd_st.Aprove_ps_st := l_Aprove_ps_st;
        Check_pd_st.IsReject := l_IsReject;
        Check_pd_st.Reject_ps_st := l_Reject_ps_st;
        g_Check_pd_st (g_Check_pd_st.COUNT) := Check_pd_st;
    END;

    --========================================
    PROCEDURE set_Rec_Check_ps_st (l_ch_ps_st       VARCHAR2,
                                   l_IsAprove       VARCHAR2,
                                   l_Aprove_pd_st   VARCHAR2,
                                   l_IsReject       VARCHAR2,
                                   l_Reject_pd_st   VARCHAR2)
    IS
        Check_ps_st   Type_Rec_Check_ps_st;
    BEGIN
        g_Check_ps_st.EXTEND;
        Check_ps_st.ch_ps_st := l_ch_ps_st;
        Check_ps_st.IsAprove := l_IsAprove;
        Check_ps_st.Aprove_pd_st := l_Aprove_pd_st;
        Check_ps_st.IsReject := l_IsReject;
        Check_ps_st.Reject_pd_st := l_Reject_pd_st;
        g_Check_ps_st (g_Check_ps_st.COUNT) := Check_ps_st;
    END;

    --========================================
    PROCEDURE Set_app_period (p_app_tp    VARCHAR2,
                              p_pd_nst    NUMBER,
                              p_tp        VARCHAR2,
                              p_ndt       NUMBER,
                              p_nda       NUMBER,
                              p_correct   NUMBER DEFAULT 0)
    IS
        l_app_period   Type_Rec_app_period;
    BEGIN
        g_app_period.EXTEND;
        l_app_period.pe_app_tp := p_app_tp;
        l_app_period.pe_pd_nst := p_pd_nst;
        l_app_period.pe_tp := p_tp;
        l_app_period.pe_ndt := p_ndt;
        l_app_period.pe_nda := p_nda;
        l_app_period.pe_correct := p_correct;
        g_app_period (g_app_period.COUNT) := l_app_period;
    END;

    --========================================
    FUNCTION Get_app_period
        RETURN Type_Tbl_app_period
        PIPELINED
    IS
    BEGIN
        IF g_app_period.COUNT > 0
        THEN
            FOR i IN g_app_period.FIRST .. g_app_period.LAST
            LOOP
                PIPE ROW (g_app_period (i));
            END LOOP;
        END IF;

        RETURN;
    END;
--========================================
BEGIN
    Set_Rec_Check_pd_st ('R0',
                         'F',
                         '',
                         'F',
                         '');
    Set_Rec_Check_pd_st ('R1',
                         'F',
                         '',
                         'F',
                         '');
    Set_Rec_Check_pd_st ('P',
                         'F',
                         'S,R',
                         'F',
                         '');
    Set_Rec_Check_pd_st ('K',
                         'F',
                         'S,R',
                         'T',
                         'S');
    Set_Rec_Check_pd_st ('S',
                         'F',
                         '',
                         'T',
                         'R,NR');

    Set_Rec_Check_ps_st ('P',
                         'F',
                         'P',
                         'F',
                         '');
    Set_Rec_Check_ps_st ('S',
                         'F',
                         'K',
                         'T',
                         'K');
    Set_Rec_Check_ps_st ('R',
                         'F',
                         '',
                         'T',
                         'S');
    Set_Rec_Check_ps_st ('NR',
                         'F',
                         '',
                         'T',
                         'S');

    Set_app_period ('Z',
                    23,
                    'START',
                    10342,
                    8625);                            --Дата початку відпустки

    Set_app_period ('FP',
                    901,
                    'START',
                    10205,
                    2688);
    Set_app_period ('FP',
                    901,
                    'STOP',
                    10205,
                    2689);
    Set_app_period ('FP',
                    901,
                    'STOP',
                    10325,
                    8524);                                           --#106780

    Set_app_period ('FP',
                    275,
                    'START',
                    10328,
                    8577);                                           --#109903
    Set_app_period ('FP',
                    275,
                    'START',
                    10329,
                    8579);                                           --#109903
    Set_app_period ('FP',
                    275,
                    'STOP',
                    10328,
                    8577,
                    -1);                                             --#109903
    Set_app_period ('FP',
                    275,
                    'STOP',
                    10329,
                    8579,
                    -1);                                             --#109903

    Set_app_period ('FP',
                    275,
                    'START',
                    10318,
                    8488);                                                 --#
    Set_app_period ('FP',
                    275,
                    'START',
                    661,
                    2666);                                                 --#
    Set_app_period ('FP',
                    275,
                    'START',
                    662,
                    2667);                                                 --#


    Set_app_period ('Z',
                    1201,
                    'START',
                    10323,
                    8522);                                      --Дата початку
    Set_app_period ('Z',
                    1201,
                    'STOP',
                    10323,
                    8523);                                    --Дата завершеня
END;
/