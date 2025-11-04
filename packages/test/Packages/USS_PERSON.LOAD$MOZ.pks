/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$MOZ
IS
    -- Author  : KELATEV
    -- Created : 24.12.2024 12:51:26
    -- Purpose : Отримання даних від МОЗ

    Pkg          CONSTANT VARCHAR2 (50) := 'LOAD$MOZ';

    l_Date_Frm   CONSTANT VARCHAR2 (50) := 'YYYY-MM-DD"T"hh24:mi:ss';

    TYPE r_Numident_Data IS RECORD
    (
        Numident       NUMBER,
        No_Numident    VARCHAR2 (10)
    );

    TYPE r_Document IS RECORD
    (
        Doc_Tp    VARCHAR2 (10),
        Doc_Sn    VARCHAR2 (50)
    );

    TYPE r_Org_Data IS RECORD
    (
        Org_Name          VARCHAR2 (250),
        Org_Id            VARCHAR2 (100),
        Region_Id         VARCHAR2 (20),
        Region_Name       VARCHAR2 (250),
        District_Id       VARCHAR2 (20),
        District_Name     VARCHAR2 (250),
        Community_Id      VARCHAR2 (20),
        Community_Name    VARCHAR2 (250),
        City_Id           VARCHAR2 (20),
        City_Name         VARCHAR2 (250),
        Street_Name       VARCHAR2 (250),
        Building          VARCHAR2 (100),
        Room              VARCHAR2 (50),
        Post_Code         VARCHAR2 (6)
    );

    TYPE r_Decision_Data IS RECORD
    (
        Decision_Num    VARCHAR2 (100),
        Decision_Dt     DATE
    );

    TYPE r_Disability_Data IS RECORD
    (
        Is_Group          VARCHAR2 (10),
        Start_Dt          VARCHAR2 (20),
        Group_            VARCHAR2 (10),
        Main_Diagnosis    VARCHAR2 (4000),
        Add_Diagnoses     CLOB,
        Is_Endless        VARCHAR2 (10),
        End_Dt            VARCHAR2 (20),
        Reasons           CLOB,
        Is_Prev           VARCHAR2 (10)
    );

    TYPE r_Loss_Prof_Ability_Data_Rec IS RECORD
    (
        Loss_Prof_Ability_Start_Dt    DATE,
        Loss_Prof_Ability_Perc        NUMBER,
        Loss_Prof_Ability_Cause       VARCHAR2 (10)
    );

    TYPE t_Loss_Prof_Ability_Data_Rec
        IS TABLE OF r_Loss_Prof_Ability_Data_Rec;

    TYPE r_Loss_Prof_Ability_Data IS RECORD
    (
        Is_Loss_Prof_Ability          VARCHAR2 (10),
        Disease_Dt                    DATE,
        Loss_Prof_Ability_Data_Rec    t_Loss_Prof_Ability_Data_Rec,
        Reexam_Dt                     DATE
    );

    TYPE r_Eval_Temp_Dis_Data IS RECORD
    (
        Is_Ext_Temp_Dis    VARCHAR2 (10),
        Ext_Temp_Dis_Dt    DATE
    --,Ext_Temp_Dis_Note VARCHAR2(4000)
    );

    TYPE r_Eval_Car_Needs_Data IS RECORD
    (
        Is_Car_Needed       VARCHAR2 (10),
        Is_Car_Provision    VARCHAR2 (10),
        Is_Med_Ind          VARCHAR2 (10),
        Is_Med_Contr_Ind    VARCHAR2 (10)
    );

    TYPE r_Eval_Death_Dis_Data IS RECORD
    (
        Is_Death_Dis_Conn    VARCHAR2 (10)
    );

    TYPE r_Dzr_Rec IS RECORD
    (
        Is_Dzr_Needed    VARCHAR2 (10),
        Dzr_Code         VARCHAR2 (50),
        Iso_Code         VARCHAR2 (250),
        Dzr_Name         VARCHAR2 (250),
        Iso_Code1        VARCHAR2 (250),
        Dzr_Name1        VARCHAR2 (250)
    );

    TYPE t_Dzr_Rec IS TABLE OF r_Dzr_Rec;

    TYPE r_Med_Data_Rec IS RECORD
    (
        Is_Med_Needed    VARCHAR2 (10),
        Med_Name         VARCHAR2 (250),
        Med_Needed_Dt    DATE,
        Med_Qty          NUMBER
    );

    TYPE t_Med_Data_Rec IS TABLE OF r_Med_Data_Rec;

    TYPE r_Serv_Data_Rec IS RECORD
    (
        Is_San_Trtmnt           VARCHAR2 (10),
        Is_Pfu_Rec              VARCHAR2 (10),
        Is_Oszn_Rec             VARCHAR2 (10),
        Is_Soc_Rehab            VARCHAR2 (10),
        Is_Psycholog_Rec        VARCHAR2 (10),
        Is_Psycholog_Rehab      VARCHAR2 (10),
        Is_Workplace_Arrgmnt    VARCHAR2 (10),
        Is_Job_Center_Rec       VARCHAR2 (10),
        Is_Prof_Limits          VARCHAR2 (10),
        Is_Prof_Rehab           VARCHAR2 (10),
        Is_Sports_Skills        VARCHAR2 (10),
        Is_Sports_Trainings     VARCHAR2 (10),
        Is_Sports_Needed        VARCHAR2 (10),
        Add_Needs               VARCHAR2 (4000)
    );

    TYPE r_Permanent_Care_Data_Rec IS RECORD
    (
        Is_Permanent_Care    VARCHAR2 (10)
    );

    TYPE r_Vlk_Decisions_Data IS RECORD
    (
        Is_Vlk_Decisions    VARCHAR2 (10),
        Vlk_Decisions       VARCHAR2 (4000)
    );

    TYPE r_Moz_Data IS RECORD
    (
        Req_Id                     VARCHAR2 (250),
        LN                         VARCHAR2 (250),
        Fn                         VARCHAR2 (250),
        Mn                         VARCHAR2 (250),
        Gender                     VARCHAR2 (10),
        Birth_Dt                   DATE,
        Numident_Data              r_Numident_Data,
        Document                   r_Document,
        Org_Data                   r_Org_Data,
        Eval_Dt                    DATE,
        Decision_Data              r_Decision_Data,
        Disability                 r_Disability_Data,
        Loss_Prof_Ability_Data     r_Loss_Prof_Ability_Data,
        Eval_Temp_Dis_Data         r_Eval_Temp_Dis_Data,
        Eval_Car_Needs_Data        r_Eval_Car_Needs_Data,
        Eval_Death_Dis_Data        r_Eval_Death_Dis_Data,
        Dzr_Rec                    t_Dzr_Rec,
        Med_Data_Rec               t_Med_Data_Rec,
        Serv_Data_Rec              r_Serv_Data_Rec,
        Permanent_Care_Data_Rec    r_Permanent_Care_Data_Rec,
        Vlk_Decisions_Data         r_Vlk_Decisions_Data
    );

    /*
    info:    Обробка запиту на Отримання інформації про інвалідність
    author:  kelatev
    request: #112487
    */
    FUNCTION Handle_Put_Moz_Data_Request (p_Request_Id     IN NUMBER,
                                          p_Request_Body   IN CLOB)
        RETURN CLOB;
END Load$moz;
/


GRANT EXECUTE ON USS_PERSON.LOAD$MOZ TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:57:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$MOZ
IS
    FUNCTION Parse_Moz_Data_Req (p_Request_Body IN CLOB)
        RETURN r_Moz_Data
    IS
        l_Data   r_Moz_Data;

        FUNCTION Clear_Dzr_Code (p_Code IN VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN TRIM (REPLACE (p_Code, CHR (160)         /*no-break space*/
                                                   , CHR (32)        /*space*/
                                                             ));
        END;

        FUNCTION Bool_Decode (p_Code IN VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            RETURN CASE
                       WHEN p_Code = '1' THEN 'T'
                       WHEN p_Code = '0' THEN 'F'
                       ELSE p_Code
                   END;
        END;
    BEGIN
        FOR Rec
            IN (                       SELECT *
                                         FROM XMLTABLE (
                                                  '*:PutMozDataRequest'
                                                  PASSING Xmltype.Createxml (p_Request_Body)
                                                  COLUMNS Req_Id                        VARCHAR2 (250) PATH '*:ReqId',
                                                          LN                            VARCHAR2 (250) PATH '*:Ln',
                                                          Fn                            VARCHAR2 (250) PATH '*:Fn',
                                                          Mn                            VARCHAR2 (250) PATH '*:Mn',
                                                          Gender                        VARCHAR2 (10) PATH '*:Gender',
                                                          Birth_Dt                      VARCHAR2 (20) PATH '*:BirthDt',
                                                          Numident                      VARCHAR2 (20) PATH '*:NumidentData/*:Numident',
                                                          No_Numident                   VARCHAR2 (10) PATH '*:NumidentData/*:NoNumident',
                                                          Doc_Tp                        VARCHAR2 (10) PATH '*:Document/*:DocTp',
                                                          Doc_Sn                        VARCHAR2 (50) PATH '*:Document/*:DocSn',
                                                          Org_Name                      VARCHAR2 (250) PATH '*:OrgData/*:OrgName',
                                                          Org_Id                        VARCHAR2 (100) PATH '*:OrgData/*:OrgId',
                                                          Region_Id                     VARCHAR2 (20) PATH '*:OrgData/*:RegionId',
                                                          Region_Name                   VARCHAR2 (250) PATH '*:OrgData/*:RegionName',
                                                          District_Id                   VARCHAR2 (20) PATH '*:OrgData/*:DistrictId',
                                                          District_Name                 VARCHAR2 (250) PATH '*:OrgData/*:DistrictName',
                                                          Community_Id                  VARCHAR2 (20) PATH '*:OrgData/*:CommunityId',
                                                          Community_Name                VARCHAR2 (250) PATH '*:OrgData/*:CommunityName',
                                                          City_Id                       VARCHAR2 (20) PATH '*:OrgData/*:CityId',
                                                          City_Name                     VARCHAR2 (250) PATH '*:OrgData/*:CityName',
                                                          Street_Name                   VARCHAR2 (250) PATH '*:OrgData/*:StreetName',
                                                          Building                      VARCHAR2 (100) PATH '*:OrgData/*:Building',
                                                          Room                          VARCHAR2 (50) PATH '*:OrgData/*:Room',
                                                          Post_Code                     VARCHAR2 (6) PATH '*:OrgData/*:PostCode',
                                                          Eval_Dt                       VARCHAR2 (20) PATH '*:EvalDt',
                                                          Decision_Num                  VARCHAR2 (100) PATH '*:DecisionData/*:DecisionNum',
                                                          Decision_Dt                   VARCHAR2 (20) PATH '*:DecisionData/*:DecisionDt',
                                                          Is_Group                      VARCHAR2 (10) PATH '*:DisabilityData/*:IsGroup',
                                                          Start_Dt                      VARCHAR2 (20) PATH '*:DisabilityData/*:StartDt',
                                                          Group_                        VARCHAR2 (10) PATH '*:DisabilityData/*:Group',
                                                          Main_Diagnosis                VARCHAR2 (4000) PATH '*:DisabilityData/*:MainDiagnosis',
                                                          Add_Diagnoses                 XMLTYPE PATH '*:DisabilityData/*:AddDiagnoses',
                                                          Is_Endless                    VARCHAR2 (10) PATH '*:DisabilityData/*:IsEndless',
                                                          End_Dt                        VARCHAR2 (20) PATH '*:DisabilityData/*:EndDt',
                                                          Reasons                       XMLTYPE PATH '*:DisabilityData/*:Reasons',
                                                          Is_Prev                       VARCHAR2 (10) PATH '*:DisabilityData/*:IsPrev',
                                                          Is_Loss_Prof_Ability          VARCHAR2 (10) PATH '*:LossProfAbilityData/*:IsLossProfAbility',
                                                          Disease_Dt                    VARCHAR2 (20) PATH '*:LossProfAbilityData/*:DiseaseDt',
                                                          Loss_Prof_Ability_Data_Rec    XMLTYPE PATH '*:LossProfAbilityData/*:LossProfAbilityDataRec',
                                                          Reexam_Dt                     VARCHAR2 (20) PATH '*:LossProfAbilityData/*:ReexamDt',
                                                          Is_Ext_Temp_Dis               VARCHAR2 (10) PATH '*:EvalTempDisData/*:IsExtTempDis',
                                                          Ext_Temp_Dis_Dt               VARCHAR2 (20) PATH '*:EvalTempDisData/*:ExtTempDisDt',
                                                          --Ext_Temp_Dis_Note VARCHAR2(4000) Path '*:EvalTempDisData/*:ExtTempDisRecom',

                                                          Is_Car_Needed                 VARCHAR2 (10) PATH '*:EvalCarNeedsData/*:IsCarNeeded',
                                                          Is_Car_Provision              VARCHAR2 (10) PATH '*:EvalCarNeedsData/*:IsCarProvision',
                                                          Is_Med_Ind                    VARCHAR2 (10) PATH '*:EvalCarNeedsData/*:IsMedInd',
                                                          Is_Med_Contr_Ind              VARCHAR2 (10) PATH '*:EvalCarNeedsData/*:IsMedContrInd',
                                                          Is_Death_Dis_Conn             VARCHAR2 (10) PATH '*:EvalDeathDisData/*:IsDeathDisConn',
                                                          Dzr_Rec                       XMLTYPE PATH '*:RehabDataRec/*:DzrRec',
                                                          Med_Data_Rec                  XMLTYPE PATH '*:MedDataRec',
                                                          Is_San_Trtmnt                 VARCHAR2 (10) PATH '*:ServDataRec/*:Medical/*:IsSanTrtmnt',
                                                          Is_Pfu_Rec                    VARCHAR2 (10) PATH '*:ServDataRec/*:Social/*:IsPfuRec',
                                                          Is_Oszn_Rec                   VARCHAR2 (10) PATH '*:ServDataRec/*:Social/*:IsOsznRec',
                                                          Is_Soc_Rehab                  VARCHAR2 (10) PATH '*:ServDataRec/*:Social/*:IsSocRehab',
                                                          Is_Psycholog_Rec              VARCHAR2 (10) PATH '*:ServDataRec/*:Educational/*:IsPsychologRec',
                                                          Is_Psycholog_Rehab            VARCHAR2 (10) PATH '*:ServDataRec/*:Educational/*:IsPsychologRehab',
                                                          Is_Workplace_Arrgmnt          VARCHAR2 (10) PATH '*:ServDataRec/*:Employment/*:IsWorkplaceArrgmnt',
                                                          Is_Job_Center_Rec             VARCHAR2 (10) PATH '*:ServDataRec/*:Employment/*:IsJobCenterRec',
                                                          Is_Prof_Limits                VARCHAR2 (10) PATH '*:ServDataRec/*:Employment/*:IsProfLimits',
                                                          Is_Prof_Rehab                 VARCHAR2 (10) PATH '*:ServDataRec/*:Employment/*:IsProfRehab',
                                                          Is_Sports_Skills              VARCHAR2 (10) PATH '*:ServDataRec/*:SportsRehab/*:IsSportsSkills',
                                                          Is_Sports_Trainings           VARCHAR2 (10) PATH '*:ServDataRec/*:SportsRehab/*:IsSportsTrainings',
                                                          Is_Sports_Needed              VARCHAR2 (10) PATH '*:ServDataRec/*:SportsRehab/*:IsSportsNeeded',
                                                          Add_Needs                     VARCHAR2 (4000) PATH '*:ServDataRec/*:AddNeeds',
                                                          Is_Permanent_Care             VARCHAR2 (10) PATH '*:PermanentCareDataRec/*:IsPermanentCare',
                                                          Is_Vlk_Decisions              VARCHAR2 (10) PATH '*:VlkDecisionsData/*:IsVlkDecisions',
                                                          Vlk_Decisions                 XMLTYPE PATH '*:VlkDecisionsData/*:VlkDecisions'))
        LOOP
            l_Data.Req_Id := Rec.Req_Id;
            l_Data.LN := Rec.LN;
            l_Data.Fn := Rec.Fn;
            l_Data.Mn := Rec.Mn;
            l_Data.Gender := Rec.Gender;
            l_Data.Birth_Dt := Tools.Try_Parse_Dt (Rec.Birth_Dt, l_Date_Frm);

            l_Data.Numident_Data.Numident := Tools.Tnumber (Rec.Numident);
            l_Data.Numident_Data.No_Numident := Bool_Decode (Rec.No_Numident);
            l_Data.Document.Doc_Tp := Tools.Tnumber (Rec.Doc_Tp);
            l_Data.Document.Doc_Sn :=
                REGEXP_REPLACE (UPPER (REPLACE (Rec.Doc_Sn, ' ')),
                                '^null$',
                                '');

            l_Data.Org_Data.Org_Name := Rec.Org_Name;
            l_Data.Org_Data.Org_Id := Rec.Org_Id;
            l_Data.Org_Data.Region_Id := Rec.Region_Id;
            l_Data.Org_Data.Region_Name := Rec.Region_Name;
            l_Data.Org_Data.District_Id := Rec.District_Id;
            l_Data.Org_Data.District_Name := Rec.District_Name;
            l_Data.Org_Data.Community_Id := Rec.Community_Id;
            l_Data.Org_Data.Community_Name := Rec.Community_Name;
            l_Data.Org_Data.City_Id := Rec.City_Id;
            l_Data.Org_Data.City_Name := Rec.City_Name;
            l_Data.Org_Data.Street_Name := Rec.Street_Name;
            l_Data.Org_Data.Building := Rec.Building;
            l_Data.Org_Data.Room := Rec.Room;
            l_Data.Org_Data.Post_Code := Rec.Post_Code;

            l_Data.Eval_Dt := Tools.Try_Parse_Dt (Rec.Eval_Dt, l_Date_Frm);
            l_Data.Decision_Data.Decision_Num := Rec.Decision_Num;
            l_Data.Decision_Data.Decision_Dt :=
                Tools.Try_Parse_Dt (Rec.Decision_Dt, l_Date_Frm);

            l_Data.Disability.Is_Group := Bool_Decode (Rec.Is_Group);
            l_Data.Disability.Start_Dt :=
                Tools.Try_Parse_Dt (Rec.Start_Dt, l_Date_Frm);
            l_Data.Disability.Group_ := Rec.Group_;
            l_Data.Disability.Main_Diagnosis := Rec.Main_Diagnosis;
            l_Data.Disability.Is_Endless := Bool_Decode (Rec.Is_Endless);
            l_Data.Disability.End_Dt :=
                Tools.Try_Parse_Dt (Rec.End_Dt, l_Date_Frm);
            l_Data.Disability.Is_Prev := Bool_Decode (Rec.Is_Prev);
            l_Data.Loss_Prof_Ability_Data.Is_Loss_Prof_Ability :=
                Bool_Decode (Rec.Is_Loss_Prof_Ability);
            l_Data.Loss_Prof_Ability_Data.Disease_Dt :=
                Tools.Try_Parse_Dt (Rec.Disease_Dt, l_Date_Frm);
            l_Data.Loss_Prof_Ability_Data.Reexam_Dt :=
                Tools.Try_Parse_Dt (Rec.Reexam_Dt, l_Date_Frm);
            l_Data.Eval_Temp_Dis_Data.Is_Ext_Temp_Dis :=
                Bool_Decode (Rec.Is_Ext_Temp_Dis);
            l_Data.Eval_Temp_Dis_Data.Ext_Temp_Dis_Dt :=
                Tools.Try_Parse_Dt (Rec.Ext_Temp_Dis_Dt, l_Date_Frm);
            l_Data.Eval_Car_Needs_Data.Is_Car_Needed :=
                Bool_Decode (Rec.Is_Car_Needed);
            l_Data.Eval_Car_Needs_Data.Is_Car_Provision :=
                Rec.Is_Car_Provision;               --v_Ddn_Scma_Car_Provision
            l_Data.Eval_Car_Needs_Data.Is_Med_Ind :=
                Bool_Decode (Rec.Is_Med_Ind);
            l_Data.Eval_Car_Needs_Data.Is_Med_Contr_Ind :=
                Bool_Decode (Rec.Is_Med_Contr_Ind);
            l_Data.Eval_Death_Dis_Data.Is_Death_Dis_Conn :=
                Bool_Decode (Rec.Is_Death_Dis_Conn);
            l_Data.Serv_Data_Rec.Is_San_Trtmnt :=
                Bool_Decode (Rec.Is_San_Trtmnt);
            l_Data.Serv_Data_Rec.Is_Pfu_Rec := Bool_Decode (Rec.Is_Pfu_Rec);
            l_Data.Serv_Data_Rec.Is_Oszn_Rec := Bool_Decode (Rec.Is_Oszn_Rec);
            l_Data.Serv_Data_Rec.Is_Soc_Rehab :=
                Bool_Decode (Rec.Is_Soc_Rehab);
            l_Data.Serv_Data_Rec.Is_Psycholog_Rec :=
                Bool_Decode (Rec.Is_Psycholog_Rec);
            l_Data.Serv_Data_Rec.Is_Psycholog_Rehab :=
                Bool_Decode (Rec.Is_Psycholog_Rehab);
            l_Data.Serv_Data_Rec.Is_Workplace_Arrgmnt :=
                Bool_Decode (Rec.Is_Workplace_Arrgmnt);
            l_Data.Serv_Data_Rec.Is_Job_Center_Rec :=
                Bool_Decode (Rec.Is_Job_Center_Rec);
            l_Data.Serv_Data_Rec.Is_Prof_Limits :=
                Bool_Decode (Rec.Is_Prof_Limits);
            l_Data.Serv_Data_Rec.Is_Prof_Rehab :=
                Bool_Decode (Rec.Is_Prof_Rehab);
            l_Data.Serv_Data_Rec.Is_Sports_Skills :=
                Bool_Decode (Rec.Is_Sports_Skills);
            l_Data.Serv_Data_Rec.Is_Sports_Trainings :=
                Bool_Decode (Rec.Is_Sports_Trainings);
            l_Data.Serv_Data_Rec.Is_Sports_Needed :=
                Bool_Decode (Rec.Is_Sports_Needed);
            l_Data.Serv_Data_Rec.Add_Needs := Rec.Add_Needs;
            l_Data.Permanent_Care_Data_Rec.Is_Permanent_Care :=
                Bool_Decode (Rec.Is_Permanent_Care);
            l_Data.Vlk_Decisions_Data.Is_Vlk_Decisions :=
                Bool_Decode (Rec.Is_Vlk_Decisions);

            IF l_Data.Numident_Data.No_Numident = 'T'
            THEN
                l_Data.Numident_Data.Numident := NULL;
            END IF;

            BEGIN
                          SELECT RTRIM (
                                     XMLAGG (XMLELEMENT (e, Add_Diagnosis, ',').EXTRACT (
                                                 '//text()')
                                             ORDER BY Add_Diagnosis).Getclobval (),
                                     ',')
                            INTO l_Data.Disability.Add_Diagnoses
                            FROM XMLTABLE (
                                     '*:AddDiagnoses/*:AddDiagnosis'
                                     PASSING Rec.Add_Diagnoses
                                     COLUMNS Add_Diagnosis    VARCHAR2 (10) PATH '.');
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                   SELECT RTRIM (
                              XMLAGG (XMLELEMENT (e, Reason, ',').EXTRACT (
                                          '//text()')
                                      ORDER BY Reason).Getclobval (),
                              ',')
                     INTO l_Data.Disability.Reasons
                     FROM XMLTABLE ('*:Reasons/*:Reason'
                                    PASSING Rec.Reasons
                                    COLUMNS Reason    VARCHAR2 (10) PATH '.');
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                   SELECT LISTAGG (Reason, ',')
                     INTO l_Data.Vlk_Decisions_Data.Vlk_Decisions
                     FROM XMLTABLE ('*:VlkDecisions/*:VlkDecision'
                                    PASSING Rec.Vlk_Decisions
                                    COLUMNS Reason    VARCHAR2 (10) PATH '.');
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

                                   SELECT Tools.Try_Parse_Dt (Loss_Prof_Ability_Start_Dt,
                                                              l_Date_Frm)
                                              Loss_Prof_Ability_Start_Dt,
                                          Tools.Tnumber (Loss_Prof_Ability_Perc,
                                                         '9999999999999D99999',
                                                         '.')
                                              Loss_Prof_Ability_Perc,
                                          Loss_Prof_Ability_Cause
                                     BULK COLLECT INTO l_Data.Loss_Prof_Ability_Data.Loss_Prof_Ability_Data_Rec
                                     FROM XMLTABLE (
                                              '*:LossProfAbilityDataRec/*:LossProfAbilityDataRec'
                                              PASSING Rec.Loss_Prof_Ability_Data_Rec
                                              COLUMNS Loss_Prof_Ability_Start_Dt    VARCHAR2 (20) PATH '*:LossProfAbilityStartDt',
                                                      Loss_Prof_Ability_Perc        VARCHAR2 (23) PATH '*:LossProfAbilityPerc',
                                                      Loss_Prof_Ability_Cause       VARCHAR2 (10) PATH '*:LossProfAbilityCause');

                      SELECT Is_Dzr_Needed,
                             Dzr_Code,
                             Iso_Code,
                             Dzr_Name,
                             Iso_Code1,
                             Dzr_Name1
                        BULK COLLECT INTO l_Data.Dzr_Rec
                        FROM XMLTABLE (
                                 '*:DzrRec/*:DzrRec'
                                 PASSING Rec.Dzr_Rec
                                 COLUMNS Is_Dzr_Needed    VARCHAR2 (10) PATH '*:IsDzrNeeded',
                                         Dzr_Code         VARCHAR2 (50) PATH '*:DzrCode',
                                         Iso_Code         VARCHAR2 (250) PATH '*:IsoCode',
                                         Dzr_Name         VARCHAR2 (250) PATH '*:DzrName',
                                         Iso_Code1        VARCHAR2 (250) PATH '*:IsoCode1',
                                         Dzr_Name1        VARCHAR2 (250) PATH '*:DzrName1');

            IF l_Data.Dzr_Rec IS NOT NULL
            THEN
                FOR i IN 1 .. l_Data.Dzr_Rec.COUNT
                LOOP
                    l_Data.Dzr_Rec (i).Is_Dzr_Needed :=
                        Bool_Decode (l_Data.Dzr_Rec (i).Is_Dzr_Needed);
                    l_Data.Dzr_Rec (i).Iso_Code :=
                        Clear_Dzr_Code (l_Data.Dzr_Rec (i).Iso_Code);
                    l_Data.Dzr_Rec (i).Iso_Code1 :=
                        Clear_Dzr_Code (l_Data.Dzr_Rec (i).Iso_Code1);
                END LOOP;
            END IF;

                      SELECT Is_Med_Needed,
                             Med_Name                       /*V_DDN_SCMM_MED*/
                                     ,
                             Tools.Try_Parse_Dt (Med_Needed_Dt, l_Date_Frm)
                                 Med_Needed_Dt,
                             Tools.Tnumber (Med_Qty)
                                 Med_Qty
                        BULK COLLECT INTO l_Data.Med_Data_Rec
                        FROM XMLTABLE (
                                 '*:MedDataRec/*:MedDataRec'
                                 PASSING Rec.Med_Data_Rec
                                 COLUMNS Is_Med_Needed    VARCHAR2 (10) PATH '*:IsMedNeeded',
                                         Med_Name         VARCHAR2 (250) PATH '*:MedName',
                                         Med_Needed_Dt    VARCHAR2 (20) PATH '*:MedNeededDt',
                                         Med_Qty          VARCHAR2 (20) PATH '*:MedQty');

            IF l_Data.Med_Data_Rec IS NOT NULL
            THEN
                FOR i IN 1 .. l_Data.Med_Data_Rec.COUNT
                LOOP
                    l_Data.Med_Data_Rec (i).Is_Med_Needed :=
                        Bool_Decode (l_Data.Med_Data_Rec (i).Is_Med_Needed);
                END LOOP;
            END IF;
        END LOOP;

        RETURN l_Data;
    END;

    /*
    info:    Валідація заповненості обовязкових полів
    author:  kelatev
    */
    PROCEDURE Validate_Moz_Data_Req (p_Data          IN     r_Moz_Data,
                                     p_Answer_Code      OUT NUMBER,
                                     p_Answer_Text      OUT VARCHAR2)
    IS
    BEGIN
        IF p_Data.Req_Id IS NULL
        THEN
            p_Answer_Text := 'ReqId';
        ELSIF p_Data.LN IS NULL
        THEN
            p_Answer_Text := 'Ln';
        ELSIF p_Data.Fn IS NULL
        THEN
            p_Answer_Text := 'Fn';
        ELSIF p_Data.Birth_Dt IS NULL
        THEN
            p_Answer_Text := 'BirthDt';
        ELSIF p_Data.Numident_Data.No_Numident IS NULL
        THEN
            p_Answer_Text := 'NoNumident';
        ELSIF     p_Data.Numident_Data.Numident IS NULL
              AND p_Data.Numident_Data.No_Numident = 'F'
        THEN
            p_Answer_Text := 'Numident';
        ELSIF p_Data.Document.Doc_Tp IS NULL
        THEN
            p_Answer_Text := 'DocTp';
        ELSIF p_Data.Document.Doc_Sn IS NULL
        THEN
            p_Answer_Text := 'DocSn';
        ELSIF p_Data.Org_Data.Org_Name IS NULL
        THEN
            p_Answer_Text := 'OrgName';
        ELSIF p_Data.Org_Data.Org_Id IS NULL
        THEN
            p_Answer_Text := 'OrgId';
        ELSIF p_Data.Org_Data.Region_Id IS NULL
        THEN
            p_Answer_Text := 'RegionId';
        ELSIF p_Data.Org_Data.Region_Name IS NULL
        THEN
            p_Answer_Text := 'RegionName';
        ELSIF p_Data.Org_Data.Street_Name IS NULL
        THEN
            p_Answer_Text := 'StreetName';
        ELSIF p_Data.Eval_Dt IS NULL
        THEN
            p_Answer_Text := 'EvalDt';
        ELSIF p_Data.Decision_Data.Decision_Num IS NULL
        THEN
            p_Answer_Text := 'DecisionNum';
        ELSIF p_Data.Decision_Data.Decision_Dt IS NULL
        THEN
            p_Answer_Text := 'DecisionDt';
        ELSIF p_Data.Disability.Is_Group IS NULL
        THEN
            p_Answer_Text := 'IsGroup';
        ELSIF p_Data.Disability.Main_Diagnosis IS NULL
        THEN
            p_Answer_Text := 'MainDiagnosis';
        ELSIF p_Data.Loss_Prof_Ability_Data.Is_Loss_Prof_Ability IS NULL
        THEN
            p_Answer_Text := 'IsLossProfAbility';
        ELSIF p_Data.Eval_Temp_Dis_Data.Is_Ext_Temp_Dis IS NULL
        THEN
            p_Answer_Text := 'IsExtTempDis';
        ELSIF p_Data.Eval_Car_Needs_Data.Is_Car_Needed IS NULL
        THEN
            p_Answer_Text := 'IsCarNeeded';
        ELSIF p_Data.Eval_Death_Dis_Data.Is_Death_Dis_Conn IS NULL
        THEN
            p_Answer_Text := 'IsDeathDisConn';
        ELSIF p_Data.Dzr_Rec IS NULL
        THEN
            p_Answer_Text := 'DzrRec';
        ELSIF p_Data.Med_Data_Rec IS NULL
        THEN
            p_Answer_Text := 'MedDataRec';
        ELSIF p_Data.Serv_Data_Rec.Is_San_Trtmnt IS NULL
        THEN
            p_Answer_Text := 'IsSanTrtmnt';
        ELSIF p_Data.Serv_Data_Rec.Is_Pfu_Rec IS NULL
        THEN
            p_Answer_Text := 'IsPfuRec';
        ELSIF p_Data.Serv_Data_Rec.Is_Oszn_Rec IS NULL
        THEN
            p_Answer_Text := 'IsOsznRec';
        ELSIF p_Data.Serv_Data_Rec.Is_Soc_Rehab IS NULL
        THEN
            p_Answer_Text := 'IsSocRehab';
        ELSIF p_Data.Serv_Data_Rec.Is_Psycholog_Rec IS NULL
        THEN
            p_Answer_Text := 'IsPsychologRec';
        ELSIF p_Data.Serv_Data_Rec.Is_Psycholog_Rehab IS NULL
        THEN
            p_Answer_Text := 'IsPsychologRehab';
        ELSIF p_Data.Serv_Data_Rec.Is_Workplace_Arrgmnt IS NULL
        THEN
            p_Answer_Text := 'IsWorkplaceArrgmnt';
        ELSIF p_Data.Serv_Data_Rec.Is_Job_Center_Rec IS NULL
        THEN
            p_Answer_Text := 'IsJobCenterRec';
        ELSIF p_Data.Serv_Data_Rec.Is_Prof_Limits IS NULL
        THEN
            p_Answer_Text := 'IsProfLimits';
        ELSIF p_Data.Serv_Data_Rec.Is_Prof_Rehab IS NULL
        THEN
            p_Answer_Text := 'IsProfRehab';
        ELSIF p_Data.Serv_Data_Rec.Is_Sports_Skills IS NULL
        THEN
            p_Answer_Text := 'IsSportsSkills';
        ELSIF p_Data.Serv_Data_Rec.Is_Sports_Trainings IS NULL
        THEN
            p_Answer_Text := 'IsSportsTrainings';
        ELSIF p_Data.Serv_Data_Rec.Is_Sports_Needed IS NULL
        THEN
            p_Answer_Text := 'IsSportsNeeded';
        ELSIF p_Data.Permanent_Care_Data_Rec.Is_Permanent_Care IS NULL
        THEN
            p_Answer_Text := 'IsPermanentCare';
        ELSIF p_Data.Vlk_Decisions_Data.Is_Vlk_Decisions IS NULL
        THEN
            p_Answer_Text := 'IsVlkDecisions';
        ELSIF     p_Data.Vlk_Decisions_Data.Is_Vlk_Decisions = 'T'
              AND p_Data.Vlk_Decisions_Data.Vlk_Decisions IS NULL
        THEN
            p_Answer_Text := 'VlkDecisions';
        END IF;

        IF p_Answer_Text IS NULL
        THEN
            FOR i IN 1 .. p_Data.Dzr_Rec.COUNT
            LOOP
                IF p_Data.Dzr_Rec (i).Is_Dzr_Needed IS NULL
                THEN
                    p_Answer_Text := 'IsDzrNeeded';
                END IF;
            END LOOP;
        END IF;

        IF p_Answer_Text IS NULL
        THEN
            FOR i IN 1 .. p_Data.Med_Data_Rec.COUNT
            LOOP
                IF p_Data.Med_Data_Rec (i).Is_Med_Needed IS NULL
                THEN
                    p_Answer_Text := 'IsMedNeeded';
                END IF;
            END LOOP;
        END IF;

        IF p_Answer_Text IS NOT NULL
        THEN
            p_Answer_Code := 105;
            p_Answer_Text := 'Незаповнене поле "' || p_Answer_Text || '"';
        END IF;
    END;

    /*
    info:    Обробка запиту на Отримання інформації про інвалідність
    author:  kelatev
    request: #112487
    */
    FUNCTION Handle_Put_Moz_Data_Request (p_Request_Id     IN NUMBER,
                                          p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Response      XMLTYPE;
        l_Answer_Code   NUMBER;
        l_Answer_Text   VARCHAR2 (32000);
        l_Data          r_Moz_Data;

        l_Scdi_Id       NUMBER;
        l_Scmz_Id       Sc_Moz_Zoz.Scmz_Id%TYPE;
        l_Scma_Id       Sc_Moz_Assessment.Scma_Id%TYPE;

        PROCEDURE Save_Doc_Attr (
            p_Scpda_Scpo         Sc_Pfu_Document_Attr.Scpda_Scpo%TYPE,
            p_Scpda_Nda          Sc_Pfu_Document_Attr.Scpda_Nda%TYPE DEFAULT NULL,
            p_Scpda_Val_Dt       Sc_Pfu_Document_Attr.Scpda_Val_Dt%TYPE DEFAULT NULL,
            p_Scpda_Val_String   Sc_Pfu_Document_Attr.Scpda_Val_String%TYPE DEFAULT NULL)
        IS
        BEGIN
            Api$socialcard_Ext.Save_Doc_Attr (
                p_Scpda_Scpo         => p_Scpda_Scpo,
                p_Scpda_Nda          => p_Scpda_Nda,
                p_Scpda_Val_Dt       => p_Scpda_Val_Dt,
                p_Scpda_Val_String   => p_Scpda_Val_String);
        END;
    BEGIN
        BEGIN
            l_Data := Parse_Moz_Data_Req (p_Request_Body => p_Request_Body);
        EXCEPTION
            WHEN OTHERS
            THEN
                Ikis_Rbm.Api$uxp_Request.Save_Request_Error (
                    p_Ure_Ur        => p_Request_Id,
                    p_Ure_Row_Id    => 1,
                    p_Ure_Row_Num   => 1,
                    p_Ure_Error     =>
                           SQLERRM
                        || CHR (13)
                        || DBMS_UTILITY.Format_Error_Stack
                        || DBMS_UTILITY.Format_Error_Backtrace);

                l_Answer_Code := 102;
                l_Answer_Text := 'Помилка парсингу запиту';
                GOTO Resp;
        END;

        Validate_Moz_Data_Req (p_Data          => l_Data,
                               p_Answer_Code   => l_Answer_Code,
                               p_Answer_Text   => l_Answer_Text);

        IF l_Answer_Code IS NOT NULL
        THEN
            GOTO Resp;
        END IF;

        Api$socialcard_Ext.Save_Data_Ident (
            p_Scdi_Id         => l_Scdi_Id,
            p_Scdi_Sc         => NULL,
            p_Scdi_Ln         => Clear_Name (l_Data.LN),
            p_Scdi_Fn         => Clear_Name (l_Data.Fn),
            p_Scdi_Mn         => Clear_Name (l_Data.Mn),
            p_Scdi_Numident   => l_Data.Numident_Data.Numident,
            p_Scdi_Doc_Tp     => l_Data.Document.Doc_Tp,
            p_Scdi_Doc_Sn     => l_Data.Document.Doc_Sn,
            p_Scdi_Sex        => l_Data.Gender,
            p_Scdi_Birthday   => l_Data.Birth_Dt,
            p_Rn_Id           =>
                Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Request_Id),
            p_Nrt_Id          =>
                Ikis_Rbm.Api$uxp_Request.Get_Ur_Nrt (p_Request_Id),
            p_Ext_Ident       => l_Data.Req_Id);

        --Створюємо ознаку відмови від РНОКПП
        IF l_Data.Numident_Data.No_Numident = 'T'
        THEN
            DECLARE
                l_Scpo_Id   NUMBER;
            BEGIN
                Api$socialcard_Ext.Save_Document (p_Scpo_Id     => l_Scpo_Id,
                                                  p_Scpo_Scdi   => l_Scdi_Id,
                                                  p_Scpo_Ndt    => 10117);
            END;
        END IF;

        --До ідентифікуючого документу додаємо дату народження та номер документу
        DECLARE
            l_Scpo_Id   NUMBER;
        BEGIN
            Api$socialcard_Ext.Save_Document (
                p_Scpo_Id     => l_Scpo_Id,
                p_Scpo_Scdi   => l_Scdi_Id,
                p_Scpo_Ndt    => l_Data.Document.Doc_Tp);

            FOR c
                IN (SELECT a.Nda_Id            x_Nda,
                           NULL                x_String,
                           l_Data.Birth_Dt     x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Data.Document.Doc_Tp
                           AND a.Nda_Class = 'BDT'
                    UNION ALL
                    SELECT a.Nda_Id                   x_Nda,
                           l_Data.Document.Doc_Sn     x_String,
                           NULL                       x_Dt
                      FROM Uss_Ndi.v_Ndi_Document_Attr a
                     WHERE     a.Nda_Ndt = l_Data.Document.Doc_Tp
                           AND a.Nda_Class = 'DSN')
            LOOP
                Save_Doc_Attr (p_Scpda_Scpo         => l_Scpo_Id,
                               p_Scpda_Nda          => c.x_Nda,
                               p_Scpda_Val_Dt       => c.x_Dt,
                               p_Scpda_Val_String   => c.x_String);
            END LOOP;
        END;

        --Зберігаємо атрибути в довідку МСЕК, яка автоматично проставить інвалідність
        IF l_Data.Disability.Is_Group = 'T'
        THEN
            DECLARE
                l_Scpo_Id   NUMBER;
            BEGIN
                Api$socialcard_Ext.Save_Document (p_Scpo_Id     => l_Scpo_Id,
                                                  p_Scpo_Scdi   => l_Scdi_Id,
                                                  p_Scpo_Ndt    => 201);
                Save_Doc_Attr (
                    l_Scpo_Id,
                    346,
                    p_Scpda_Val_String   => l_Data.Decision_Data.Decision_Num); --серія та номер документа

                IF l_Data.Disability.Is_Endless = 'F'
                THEN
                    Save_Doc_Attr (
                        l_Scpo_Id,
                        347,
                        p_Scpda_Val_Dt   => l_Data.Disability.End_Dt); --встановлено на період до
                END IF;

                Save_Doc_Attr (
                    l_Scpo_Id,
                    348,
                    p_Scpda_Val_Dt   => l_Data.Decision_Data.Decision_Dt); --дата видачі
                Save_Doc_Attr (
                    l_Scpo_Id,
                    349,
                    p_Scpda_Val_String   =>
                        SUBSTR (l_Data.Disability.Group_, 1, 1)); --група інвалідності
                Save_Doc_Attr (l_Scpo_Id,
                               350,
                               p_Scpda_Val_Dt   => l_Data.Eval_Dt); --дата огляду
                --351--відношення до військової служби
                Save_Doc_Attr (l_Scpo_Id,
                               352,
                               p_Scpda_Val_Dt   => l_Data.Disability.Start_Dt); --дата встановлення інвалідності
                Save_Doc_Attr (
                    l_Scpo_Id,
                    353,
                    p_Scpda_Val_String   =>
                        CASE
                            WHEN INSTR (l_Data.Disability.Reasons, ',') > 0
                            THEN
                                SUBSTR (
                                    l_Data.Disability.Reasons,
                                    0,
                                      INSTR (l_Data.Disability.Reasons, ',')
                                    - 1)
                            ELSE
                                l_Data.Disability.Reasons
                        END);                           --причина інвалідності
                Save_Doc_Attr (
                    l_Scpo_Id,
                    790,
                    p_Scpda_Val_String   =>
                        CASE
                            WHEN l_Data.Serv_Data_Rec.Add_Needs = 'LLA2'
                            THEN
                                'T'
                            ELSE
                                'F'
                        END);        --потребує постійного стороннього догляду
                Save_Doc_Attr (
                    l_Scpo_Id,
                    791,
                    p_Scpda_Val_String   =>
                        SUBSTR (l_Data.Disability.Group_, 2, 1)); --підгрупа інвалідності
                Save_Doc_Attr (l_Scpo_Id,
                               1910,
                               p_Scpda_Val_Dt   => l_Data.Disability.End_Dt); --Дата чергового переогляду
                Save_Doc_Attr (
                    l_Scpo_Id,
                    2925,
                    p_Scpda_Val_String   => l_Data.Disability.Is_Endless); --Призначено довічно
                Save_Doc_Attr (l_Scpo_Id, 4188, p_Scpda_Val_String => 'T'); --МСЕК тимчасово не виконують свої повноваження
            END;
        END IF;

        Api$socialcard_Ext.Save_Moz_Zoz (
            p_Scmz_Id               => l_Scmz_Id,
            p_Scmz_Scdi             => l_Scdi_Id,
            p_Scmz_Sc               => NULL,
            p_Scmz_Org_Name         => l_Data.Org_Data.Org_Name,
            p_Scmz_Org_Id           => l_Data.Org_Data.Org_Id,
            p_Scmz_Region_Id        => l_Data.Org_Data.Region_Id,
            p_Scmz_Region_Name      => l_Data.Org_Data.Region_Name,
            p_Scmz_District_Id      => l_Data.Org_Data.District_Id,
            p_Scmz_District_Name    => l_Data.Org_Data.District_Name,
            p_Scmz_Community_Id     => l_Data.Org_Data.Community_Id,
            p_Scmz_Community_Name   => l_Data.Org_Data.Community_Name,
            p_Scmz_City_Id          => l_Data.Org_Data.City_Id,
            p_Scmz_City_Name        => l_Data.Org_Data.City_Name,
            p_Scmz_Street_Name      => l_Data.Org_Data.Street_Name,
            p_Scmz_Building         => l_Data.Org_Data.Building,
            p_Scmz_Room             => l_Data.Org_Data.Room,
            p_Scmz_Post_Code        => l_Data.Org_Data.Post_Code,
            p_Scmz_St               => NULL);

        Api$socialcard_Ext.Save_Moz_Assessment (
            p_Scma_Id                 => l_Scma_Id,
            p_Scma_Scdi               => l_Scdi_Id,
            p_Scma_Sc                 => NULL,
            p_Scma_Eval_Dt            => l_Data.Eval_Dt,
            p_Scma_Decision_Num       => l_Data.Decision_Data.Decision_Num,
            p_Scma_Decision_Dt        => l_Data.Decision_Data.Decision_Dt,
            p_Scma_Is_Group           => l_Data.Disability.Is_Group,
            p_Scma_Start_Dt           => l_Data.Disability.Start_Dt,
            p_Scma_Group              => l_Data.Disability.Group_,
            p_Scma_Main_Diagnosis     => l_Data.Disability.Main_Diagnosis,
            p_Scma_Add_Diagnoses      => l_Data.Disability.Add_Diagnoses,
            p_Scma_Is_Endless         => l_Data.Disability.Is_Endless,
            p_Scma_End_Dt             => l_Data.Disability.End_Dt,
            p_Scma_Reasons            => l_Data.Disability.Reasons, --V_DDN_INV_REASON
            p_Scma_Is_Prev            => l_Data.Disability.Is_Prev,
            p_Scma_Is_Loss_Prof_Ability   =>
                l_Data.Loss_Prof_Ability_Data.Is_Loss_Prof_Ability,
            p_Scma_Disease_Dt         =>
                l_Data.Loss_Prof_Ability_Data.Disease_Dt,
            --p_Scma_Loss_Prof_Ability_Dt    => Rec.Loss_Prof_Ability_Start_Dt,
            --p_Scma_Loss_Prof_Ability_Perc  => Rec.Loss_Prof_Ability_Perc,
            --p_Scma_Loss_Prof_Ability_Cause => Rec.Loss_Prof_Ability_Cause, --V_DDN_SCMA_LPAC
            p_Scma_Reexam_Dt          => l_Data.Loss_Prof_Ability_Data.Reexam_Dt,
            p_Scma_Is_Ext_Temp_Dis    =>
                l_Data.Eval_Temp_Dis_Data.Is_Ext_Temp_Dis,
            p_Scma_Ext_Temp_Dis_Dt    =>
                l_Data.Eval_Temp_Dis_Data.Ext_Temp_Dis_Dt,
            --p_Scma_Ext_Temp_Dis_Note    => l_Data.Eval_Temp_Dis_Data.Ext_Temp_Dis_Note,
            p_Scma_Is_Car_Needed      =>
                l_Data.Eval_Car_Needs_Data.Is_Car_Needed,
            p_Scma_Is_Car_Provision   =>
                l_Data.Eval_Car_Needs_Data.Is_Car_Provision, --v_Ddn_Scma_Car_Provision
            p_Scma_Is_Med_Ind         => l_Data.Eval_Car_Needs_Data.Is_Med_Ind,
            p_Scma_Is_Med_Contr_Ind   =>
                l_Data.Eval_Car_Needs_Data.Is_Med_Contr_Ind,
            p_Scma_Is_Death_Dis_Conn   =>
                l_Data.Eval_Death_Dis_Data.Is_Death_Dis_Conn,
            p_Scma_Is_San_Trtmnt      => l_Data.Serv_Data_Rec.Is_San_Trtmnt,
            p_Scma_Is_Pfu_Rec         => l_Data.Serv_Data_Rec.Is_Pfu_Rec,
            p_Scma_Is_Oszn_Rec        => l_Data.Serv_Data_Rec.Is_Oszn_Rec,
            p_Scma_Is_Soc_Rehab       => l_Data.Serv_Data_Rec.Is_Soc_Rehab,
            p_Scma_Is_Psycholog_Rec   => l_Data.Serv_Data_Rec.Is_Psycholog_Rec,
            p_Scma_Is_Psycholog_Rehab   =>
                l_Data.Serv_Data_Rec.Is_Psycholog_Rehab,
            p_Scma_Is_Workplace_Arrgmnt   =>
                l_Data.Serv_Data_Rec.Is_Workplace_Arrgmnt,
            p_Scma_Is_Job_Center_Rec   =>
                l_Data.Serv_Data_Rec.Is_Job_Center_Rec,
            p_Scma_Is_Prof_Limits     => l_Data.Serv_Data_Rec.Is_Prof_Limits,
            p_Scma_Is_Prof_Rehab      => l_Data.Serv_Data_Rec.Is_Prof_Rehab,
            p_Scma_Is_Sports_Skills   => l_Data.Serv_Data_Rec.Is_Sports_Skills,
            p_Scma_Is_Sports_Trainings   =>
                l_Data.Serv_Data_Rec.Is_Sports_Trainings,
            p_Scma_Is_Sports_Needed   => l_Data.Serv_Data_Rec.Is_Sports_Needed,
            p_Scma_Add_Needs          => l_Data.Serv_Data_Rec.Add_Needs, --V_DDN_SCMA_ADD_NEEDS
            p_Scma_St                 => NULL,
            p_Scma_Is_Permanent_Care   =>
                l_Data.Permanent_Care_Data_Rec.Is_Permanent_Care,
            p_Scma_Is_Vlk_Decisions   =>
                l_Data.Vlk_Decisions_Data.Is_Vlk_Decisions,
            p_Scma_Vlk_Decisions      =>
                l_Data.Vlk_Decisions_Data.Vlk_Decisions);

        IF l_Data.Loss_Prof_Ability_Data.Loss_Prof_Ability_Data_Rec
               IS NOT NULL
        THEN
            FOR i
                IN 1 ..
                   l_Data.Loss_Prof_Ability_Data.Loss_Prof_Ability_Data_Rec.COUNT
            LOOP
                DECLARE
                    l_Item      r_Loss_Prof_Ability_Data_Rec
                        := l_Data.Loss_Prof_Ability_Data.Loss_Prof_Ability_Data_Rec (
                               i);
                    l_Scmd_Id   NUMBER;
                BEGIN
                    Api$socialcard_Ext.Save_Moz_Loss_Prof_Ability (
                        p_Scml_Id                        => l_Scmd_Id,
                        p_Scml_Scdi                      => l_Scdi_Id,
                        p_Scml_Sc                        => NULL,
                        p_Scml_Loss_Prof_Ability_Dt      =>
                            l_Item.Loss_Prof_Ability_Start_Dt,
                        p_Scml_Loss_Prof_Ability_Perc    =>
                            l_Item.Loss_Prof_Ability_Perc,
                        p_Scml_Loss_Prof_Ability_Cause   =>
                            l_Item.Loss_Prof_Ability_Cause,  --V_DDN_SCMA_LPAC
                        p_Scml_St                        => NULL);
                END;
            END LOOP;
        END IF;

        IF l_Data.Dzr_Rec IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Dzr_Rec.COUNT
            LOOP
                DECLARE
                    l_Item      r_Dzr_Rec := l_Data.Dzr_Rec (i);
                    l_Scmd_Id   NUMBER;
                BEGIN
                    Api$socialcard_Ext.Save_Moz_Dzr_Recomm (
                        p_Scmd_Id              => l_Scmd_Id,
                        p_Scmd_Scdi            => l_Scdi_Id,
                        p_Scmd_Sc              => NULL,
                        p_Scmd_Is_Dzr_Needed   => l_Item.Is_Dzr_Needed,
                        p_Scmd_Dzr_Code        => l_Item.Dzr_Code,
                        p_Scmd_Iso_Code        => l_Item.Iso_Code,
                        p_Scmd_Dzr_Name        => l_Item.Dzr_Name,
                        p_Scmd_Iso_Code1       => l_Item.Iso_Code1,
                        p_Scmd_Dzr_Name1       => l_Item.Dzr_Name1,
                        p_Scmd_Wrn             => NULL,
                        p_Scmd_St              => NULL);
                END;
            END LOOP;
        END IF;

        IF l_Data.Med_Data_Rec IS NOT NULL
        THEN
            FOR i IN 1 .. l_Data.Med_Data_Rec.COUNT
            LOOP
                DECLARE
                    l_Item      r_Med_Data_Rec := l_Data.Med_Data_Rec (i);
                    l_Scmm_Id   NUMBER;
                BEGIN
                    Api$socialcard_Ext.Save_Moz_Med_Data_Recomm (
                        p_Scmm_Id              => l_Scmm_Id,
                        p_Scmm_Scdi            => l_Scdi_Id,
                        p_Scmm_Sc              => NULL,
                        p_Scmm_Is_Med_Needed   => l_Item.Is_Med_Needed,
                        p_Scmm_Med_Name        => l_Item.Med_Name, --V_DDN_SCMM_MED
                        p_Scmm_Med_Needed_Dt   => l_Item.Med_Needed_Dt,
                        p_Scmm_Med_Qty         => l_Item.Med_Qty,
                        p_Scmm_St              => NULL);
                END;
            END LOOP;
        END IF;

        IF l_Scdi_Id IS NOT NULL
        THEN
            l_Answer_Code := 1;
            l_Answer_Text := 'Запит виконано успішно';
        END IF;

       <<resp>>
        SELECT XMLELEMENT (
                   "PutMozDataResponse",
                   Ikis_Rbm.Api$uxp_Univ.Answer_Xml (
                       p_Code   => l_Answer_Code,
                       p_Text   => l_Answer_Text))
          INTO l_Response
          FROM DUAL;

        RETURN l_Response.Getclobval;
    END;
END Load$moz;
/