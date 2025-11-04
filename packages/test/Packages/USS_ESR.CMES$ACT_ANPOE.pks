/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_ANPOE
IS
    -- Author  : AKOMISAROV
    -- Created : 23.10.2023 18:31:25
    -- Purpose : Акт про надання повнолітній особі соціальних послуг екстрено (кризово)

    Pkg                    VARCHAR2 (50) := 'CMES$ACT_ANPOE';

    с_Form_Ndt   CONSTANT NUMBER := 803;


    TYPE r_Act_Anpoe IS RECORD
    (
        At_Pc                 Act.At_Pc%TYPE,
        At_Dt                 TIMESTAMP,
        At_Org                Act.At_Org%TYPE,
        At_Sc                 Act.At_Sc%TYPE,
        At_Rnspm              Act.At_Rnspm%TYPE,
        At_Ap                 Act.At_Ap%TYPE,
        At_Case_Class         Act.At_Case_Class%TYPE,
        At_Action_Start_Dt    TIMESTAMP,
        At_Action_Stop_Dt     TIMESTAMP,
        At_Notes              Act.At_Notes%TYPE,
        At_Family_Info        Act.At_Family_Info%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Conclusion_Tp      Act.At_Conclusion_Tp%TYPE,
        At_Form_Tp            Act.At_Form_Tp%TYPE,
        At_Decision           NUMBER
    );

    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Sections          IN     CLOB,
                        p_At_Signers           IN     CLOB,
                        p_At_Services          IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Results           IN     CLOB);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Services_Cur       OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Rc (p_Res OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- ОТРИМУВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- НАДАВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    -----------------------------------------------------------
    -- ПЕРЕВОД Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- В СТАН "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    -----------------------------------------------------------
    -- ПЕРЕВОД Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     );

    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER);

    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Set_Cm (p_At_Id IN NUMBER,                          --Ід ріщення
                                         p_At_Cu IN NUMBER --Ід користувача КМа, який буде вести випадок
                                                          );

    FUNCTION Get_At_Main_Atp (p_at_id IN NUMBER)
        RETURN NUMBER;
END Cmes$act_Anpoe;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPOE TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPOE TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:19 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_ANPOE
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Anpoe
    IS
        l_Result   r_Act_Anpoe;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Anpoe', TRUE)
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу акту: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------
    --        ЗБЕРЕЖЕННЯ ПРО НАДАННЯ ПОВНОЛІТНІЙ ОСОБІ СОЦІАЛЬНИХ ПОСЛУГ ЕКСТРЕНО (КРИЗОВО)
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Sections          IN     CLOB,
                        p_At_Signers           IN     CLOB,
                        p_At_Services          IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Results           IN     CLOB)
    IS
        l_Cu_Id             NUMBER;
        l_At_Cu             NUMBER;
        l_At_St_Old         VARCHAR2 (10);
        l_Already_Exist     NUMBER;
        l_Act               r_Act_Anpoe;
        l_Persons           Api$act.t_At_Persons;
        l_Sections          Api$act.t_At_Sections;
        l_Signers           Api$act.t_At_Signers;
        l_Services          Api$act.t_At_Services;
        l_Individual_Plan   Api$act.t_At_Individual_Plan;
        l_Results           Api$act.t_At_Results;
    BEGIN
        /*XN Проект
        XV Очікує підписання
        XS Підписано отримувачем
        XP Затверджено
        XD Скасовано
        XR Відхилено*/

        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        l_Act := Parse_Act (p_Act);

        IF     l_Act.At_Rnspm IS NOT NULL
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_SPEC')
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_CM')
        THEN
            Raise_Application_Error (-20000, 'Некоректно вакзано надавача');
        END IF;

        --Редагування акту
        IF NVL (p_At_Id, -1) > 0
        THEN
            SELECT a.At_Cu, a.At_St
              INTO l_At_Cu, l_At_St_Old
              FROM Act a
             WHERE a.At_Id = p_At_Id;

            IF l_At_Cu IS NULL OR l_At_Cu <> NVL (l_Cu_Id, -1)
            THEN
                Api$act.Raise_Unauthorized;
            END IF;

            IF NVL (l_At_St_Old, '-') <> 'XN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування акту в поточному статусі заборонено');
            END IF;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'ANPOE'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('XR', 'XD')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Already_Exist = 1
        THEN
            Raise_Application_Error (
                -20000,
                'По цьому випадку вже існує акт Акт про надання повнолітній особі соціальних послуг екстрено (кризово)');
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Sections := Api$act.Parse_Sections (p_At_Sections);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Services := Api$act.Parse_Services (p_At_Services);

        l_Results := Api$act.Parse_At_Results (p_At_Results);
        l_Individual_Plan :=
            Api$act.Parse_Individual_Plan (p_At_Individual_Plan);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);


        FOR vSsNeeds IN (SELECT dic_name FROM uss_ndi.V_DDN_SS_NEEDS)
        LOOP
            l_Act.At_Family_Info :=
                TRIM (
                    REPLACE (l_Act.At_Family_Info,
                             vSsNeeds.Dic_Name || ';',
                             ''));
        END LOOP;

        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'ANPOE',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Ap               => l_Act.At_Ap,
            p_At_St               => 'XN',
            p_At_Src              => p_At_Src,
            p_At_Case_Class       => l_Act.At_Case_Class,
            p_At_Main_Link_Tp     => 'DECISION',
            p_At_Main_Link        => l_Act.At_Decision,
            p_At_Action_Start_Dt   =>
                NULLIF (l_Act.At_Action_Start_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Action_Stop_Dt   =>
                NULLIF (l_Act.At_Action_Stop_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Notes            => l_Act.At_Notes,
            p_At_Family_Info      => l_Act.At_Family_Info,
            p_At_Live_Address     => l_Act.At_Live_Address,
            p_At_Cu               => l_Cu_Id,
            p_At_Conclusion_Tp    => l_Act.At_Conclusion_Tp,
            p_At_Form_Tp          => l_Act.At_Form_Tp,
            p_New_Id              => p_At_Id);

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Sections (p_At_Id      => p_At_Id,
                               p_Sections   => l_Sections,
                               p_Persons    => l_Persons);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);
        Api$act.Save_Services (p_At_Id => p_At_Id, p_Services => l_Services);

        Api$act.Save_Individual_Plans (
            p_At_Id              => p_At_Id,
            p_Individual_Plans   => l_Individual_Plan);

        --#110355
        Api$act.Check_Atp_Z_Exists_Incorrect (p_At_Id);

        FOR xx
            IN (SELECT t.atr_id, p.atip_id, p.New_Id
                  FROM TABLE (l_Results)  t
                       JOIN TABLE (l_Individual_Plan) p
                           ON (p.atip_id = t.atr_atip)
                 WHERE p.atip_id IS NULL OR p.atip_id < 0)
        LOOP
            FOR yy IN l_Results.FIRST .. l_Results.LAST
            LOOP
                IF (xx.atr_id = l_Results (yy).atr_id)
                THEN
                    l_Results (yy).atr_atip := xx.new_id;
                END IF;
            END LOOP;
        END LOOP;

        Api$act.Save_At_Results (p_At_Id => p_At_Id, p_Results => l_Results);

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (p_at_id => p_At_Id, p_ndt_id => с_Form_Ndt);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'XN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    --#108600
    FUNCTION Get_At_Main_Atp (p_at_id IN NUMBER)
        RETURN NUMBER
    IS
        l_At            ACT%ROWTYPE;
        l_At_main_atp   VARCHAR2 (10);
        l_Res           NUMBER;
    BEGIN
        SELECT *
          INTO l_At
          FROM act
         WHERE at_id = p_at_id;

        l_At_main_atp := Api$act.Get_Section_Attr_Val_Str (l_At.at_id, 2033);

        IF l_At_main_atp IS NULL
        THEN
            l_At_main_atp := Api$appeal.Get_Ap_Attr_Str (l_At.at_ap, 2033);
        END IF;

        IF l_At_main_atp IS NULL
        THEN
            SELECT MAX (Atp_id)
              INTO l_Res
              FROM At_Person
             WHERE Atp_At = p_at_id AND Atp_sc = l_at.at_sc;
        ELSIF l_At_main_Atp = 'Z'
        THEN
            SELECT MAX (Atp_Id)
              INTO l_Res
              FROM (  SELECT Atp_Id
                        FROM At_Person
                       WHERE     Atp_At = p_at_id
                             AND NVL (Atp_tp, ATP_APP_TP) IN ('OS', 'Z')
                    ORDER BY CASE
                                 WHEN Atp_tp = 'OS' THEN 1
                                 WHEN Atp_tp = 'Z' THEN 2
                                 ELSE 3
                             END)
             WHERE ROWNUM = 1;
        ELSIF l_At_main_Atp = 'FM'
        THEN
            SELECT MAX (Atp_Id)
              INTO l_Res
              FROM (  SELECT Atp_Id
                        FROM At_Person
                       WHERE     Atp_At = p_at_id
                             AND NVL (Atp_tp, ATP_APP_TP) IN ('OS', 'Z')
                    ORDER BY CASE
                                 WHEN Atp_tp = 'Z' THEN 1
                                 WHEN Atp_tp = 'OS' THEN 2
                                 ELSE 3
                             END)
             WHERE ROWNUM = 1;
        END IF;

        RETURN l_Res;
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.at_id,
                   a.at_tp,
                   a.at_pc,
                   a.at_num,
                   a.at_dt,
                   a.at_org,
                   a.at_sc,
                   a.at_rnspm,
                   a.at_rnp,
                   a.at_ap,
                   a.at_st,
                   a.at_src,
                   a.at_case_class,
                   a.at_main_link_tp,
                   a.at_main_link,
                   a.at_action_start_dt,
                   a.at_action_stop_dt,
                   a.at_notes,
                   --a.at_family_info,
                   --a.at_live_address,
                   a.at_wu,
                   a.at_cu,
                   a.at_conclusion_tp,
                   a.at_form_tp,
                   a.at_redirect_rnspm,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                      --#108600
                      CASE
                          WHEN Api$act.Get_Section_Attr_Val_Str (a.at_id,
                                                                 2033)
                                   IS NOT NULL
                          THEN
                                 (SELECT MAX (dic_name)
                                    FROM uss_ndi.V_DDN_SS_NEEDS
                                   WHERE dic_value =
                                         Api$act.Get_Section_Attr_Val_Str (
                                             a.at_id,
                                             2033))
                              || '; '
                          WHEN Api$appeal.Get_Ap_Attr_Str (a.at_ap, 2033)
                                   IS NOT NULL
                          THEN
                                 (SELECT MAX (dic_name)
                                    FROM uss_ndi.V_DDN_SS_NEEDS
                                   WHERE dic_value =
                                         Api$appeal.Get_Ap_Attr_Str (a.at_ap,
                                                                     2033))
                              || '; '
                      END
                   || CASE
                          WHEN TRIM (a.at_family_info) IS NOT NULL
                          THEN
                              a.At_Family_Info
                          ELSE
                                 atp.atp_ln
                              || ' '
                              || atp.atp_fn
                              || ' '
                              || atp.atp_mn
                      END
                       At_Family_Info,
                   CASE
                       WHEN TRIM (a.At_Live_Address) IS NOT NULL
                       THEN
                           a.At_Live_Address
                       ELSE
                           atp.atp_fact_address
                   END
                       At_Live_Address                                     --,
              --api$act.Get_At_Decline_Reason_Text(a.at_id) decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Anpoe_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
                   LEFT JOIN At_Person atp
                       ON     a.at_id = atp.atp_at
                          AND atp.atp_id =
                              CMES$ACT_ANPOE.Get_At_Main_Atp (p_At_Id)
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   --ОСЗН
                   o.Org_Name
                       AS At_Org_Name,
                   --Ким сформовано
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Найменування організації
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   a.At_Main_Link
                       AS At_Decision,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Anpoe_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_At_Main_Link    IN     NUMBER,
                           p_At_Pc           IN     NUMBER,
                           p_At_Ap           IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_Cm',
            p_obj_tp   => 'CMES_CU_ID',
            p_obj_id   => l_Cu_Id,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ' p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_At_St='
                || p_At_St
                || ' p_At_Main_Link='
                || p_At_Main_Link
                || ' p_At_Pc='
                || p_At_Pc
                || ' p_At_Ap='
                || p_At_Ap
                || ' p_At_Case_Class='
                || p_At_Case_Class
                || ' p_Ap_Is_Correct='
                || p_Ap_Is_Correct);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPOE'
                   AND (a.At_Cu = l_Cu_Id)
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND NVL (a.At_Case_Class, '-') =
                       NVL (p_At_Case_Class, NVL (a.At_Case_Class, '-'))
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap)
                   AND (   p_Ap_Is_Correct IS NULL
                        OR API$APPEAL.Is_Appeal_Maked_Correct (at_ap) =
                           p_Ap_Is_Correct);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Rc (p_Res OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_Rc',
                   p_obj_tp           => 'CMES_CU_SC',
                   p_obj_id           => l_Cu_Sc,
                   p_regular_params   => '');

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, де поточний користувач є серед підписантів,
        --та які хоч раз переводились до стану "Очікує підписання"
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPOE'
                   AND (   a.At_Sc = l_Cu_Sc
                        OR EXISTS
                               (SELECT 1
                                  FROM At_Signers s
                                 WHERE     s.Ati_At = a.At_Id
                                       AND s.History_Status = 'A'
                                       AND s.Ati_Sc = l_Cu_Sc))
                   AND EXISTS
                           (SELECT 1
                              FROM At_Log l
                             WHERE l.Atl_At = a.At_Id AND l.Atl_St = 'AV');

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    -----------------------------------------------------------
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_Pr',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ' p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ' p_At_Num='
                || p_At_Num
                || ' p_At_St='
                || p_At_St
                || ' p_At_Case_Class='
                || p_At_Case_Class);

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_Pr',
                       p_obj_tp           => 'CMES_OWNER_ID',
                       p_obj_id           => p_Cmes_Owner_Id,
                       p_regular_params   => 'Insufficient privileges.');
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPOE'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (   p_At_Case_Class IS NULL
                        OR a.At_Case_Class = p_At_Case_Class);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --    ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'ANPOE'
                       AND a.At_Rnspm = p_Cmes_Owner_Id;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'ANPOE'
                       AND (   a.At_Sc = l_Sc_Id
                            OR EXISTS
                                   (SELECT 1
                                      FROM At_Signers s
                                     WHERE     s.Ati_At = a.At_Id
                                           AND s.History_Status = 'A'
                                           AND s.Ati_Sc = l_Sc_Id))
                       AND EXISTS
                               (SELECT 1
                                  FROM At_Log l
                                 WHERE     l.Atl_At = a.At_Id
                                       AND l.Atl_St IN ('XN',
                                                        'XV',
                                                        'XS',
                                                        'XR',
                                                        'XP'));
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_ANPOE.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        Get_Act_List (p_Acts);
    END;


    --------------------------------------------------------------
    --           ОТРИМАННЯ ПОСЛУГ
    --------------------------------------------------------------
    PROCEDURE Get_Services (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Nst_Name AS Ats_Nst_Name
              --todo: уточнити щодо статусу
              FROM At_Service  s
                   JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
             WHERE s.Ats_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ РЕЗУЛЬТАТУ ІНДИВІДУАЛЬНОГО ПЛАНУ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Results (p_At_Id         IN     NUMBER,
                           p_Results_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Results_Cur FOR
            SELECT t.*,
                   p.Atip_Desc                                              AS Atr_Atip_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (t.Atr_Redirect_Rnspm)    AS Atr_Redirect_Rnspm_Name
              FROM At_Results  t
                   JOIN At_Individual_Plan p ON (p.Atip_Id = t.Atr_Atip)
             WHERE     t.Atr_At = p_At_Id
                   AND NVL (t.history_status, 'A') = 'A'
                   AND NVL (p.history_status, 'A') = 'A';
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Services_Cur       OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_Anpoe.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => NULL);

        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'ANPOE');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Services (p_At_Id, p_Services_Cur);

        Api$act.Get_Indivilual_Plan (p_At_Id, p_Ip_Cur);
        Get_Results (p_At_Id, p_Results_Cur);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);
        Api$act.Get_Form_File (p_At_Id       => p_At_Id,
                               p_Form_Ndt    => с_Form_Ndt,
                               p_Atd_Dh      => p_Atd_Dh,
                               p_File_Code   => p_File_Code);
    END;

    -----------------------------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ (з кодами підписів через кому)
    -----------------------------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);
        Api$act.Get_Form_File (
            p_At_Id                  => p_At_Id,
            p_Form_Ndt               => с_Form_Ndt,
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        --Хто так заглушки робить?!
        --Для цього є процедура Api$Act_Rpt.Build_Stub, яка генерує пусту форму
        --Raise_Application_Error(-20000, 'Заглушка, поки немає "ДРУКОВАНА ФОРМА АКТУ"');
        Api$act.Get_Form_File (
            p_At_Id             => p_At_Id,
            p_At_Prj_St         => 'XN',
            p_Form_Ndt          => с_Form_Ndt,
            p_Form_Build_Proc   => 'Api$Act_Rpt.ACT_DOC_803_R1',
            p_Doc_Cur           => p_Doc_Cur);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => с_Form_Ndt,
                              p_Doc       => p_Doc);
    END;


    /*
    3) КМ:
    - створює проєкт Акту, заповнює необхідні дані, зберігає їх – статус XN
    - КМ створює друковану форму Акту та підписує її – статус XV, рішення відображається в кабінеті ОСП
    4) ОСП:
    - відхиляє Акт – статус XR, КМ має створити новий Акт
    або
    - підписує його – статус XS, рішення відображається в кабінеті НСП
    5) НСП:
    - відхиляє Акт – статус XR, КМ має створити новий Акт
    або
    - підписує його – статус XP = точка виходу з міні-ЖЦ – в залежності від встановлених в ANPOE ознак, глобальний ЖЦ має піти відповідною гілкою
    */

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        l_st   VARCHAR2 (10) := 'XV';
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            api$act.Handle_Cm_Sign (p_at_id,
                                    l_st,
                                    'XS',
                                    с_Form_Ndt,
                                    l_st);
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'XN',
                p_At_St_New   => l_st,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- ОТРИМУВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Rc');
        Cmes$act.Set_Signed_Rc (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'XV',
                p_At_St_New   => 'XS',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- НАДАВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_cnt_803       NUMBER;
        l_atr_2031      VARCHAR2 (200);
        --l_atr_2078     VARCHAR2(200);
        l_ap_id         NUMBER;
        l_cnt_ats_new   NUMBER;

        l_new_nst       API$ACT.t_At_Services_Row;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'XS',
            p_At_St_New   => 'XP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        --#117038
        SELECT at_ap
          INTO l_ap_id
          FROM ACT
         WHERE at_id = p_At_Id;

        SELECT *
          BULK COLLECT INTO l_new_nst
          FROM at_service ats
         WHERE     ats_at = p_At_Id
               AND NOT EXISTS
                       (SELECT 1
                          FROM ap_service aps
                         WHERE     aps_ap = l_ap_id
                               AND ats.ats_nst = aps.aps_nst
                               AND aps.history_status = 'A')
               AND ats.history_status = 'A'
               AND ats.ats_nst NOT IN (401, 403, 420);

        SELECT COUNT (1) INTO l_cnt_ats_new FROM TABLE (l_new_nst);

        IF l_cnt_ats_new > 0
        THEN
            SELECT COUNT (1)
              INTO l_cnt_803
              FROM act  at
                   JOIN act all_at ON at.at_ap = all_at.at_ap
                   JOIN at_document atd
                       ON     atd.atd_at = all_at.at_id
                          AND atd_ndt = 803
                          AND HISTORY_STATUS = 'A'
             WHERE at.at_id = p_At_Id;

            l_atr_2031 := API$Act.Get_PDSP_Feature (p_At_Id, 2031, '_');
        --l_atr_2078 := API$Act.Get_PDSP_Feature(p_At_Id, 2078, '_');
        END IF;

        --Для всіх рішень по зверненню до якого привязаний акт
        FOR Rec
            IN (SELECT d.At_Id AS Decision_Id, a.at_ap
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St = 'SNR'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --#117038
            IF l_cnt_803 > 0 AND l_atr_2031 = 'T' AND l_cnt_ats_new > 0
            THEN
                FOR vI IN (SELECT *
                             FROM TABLE (l_new_nst) a)
                LOOP
                    INSERT INTO at_service (ats_id,
                                            ats_at,
                                            ats_nst,
                                            ats_at_src,
                                            ats_ss_method,
                                            ats_ss_address_tp,
                                            ats_ss_address,
                                            ats_tarif_sum,
                                            ats_act_sum,
                                            ats_rnspa,
                                            history_status,
                                            ats_st)
                         VALUES (NULL,
                                 Rec.Decision_Id,
                                 vI.ats_nst,
                                 vI.ats_at_src,
                                 vI.ats_ss_method,
                                 vI.ats_ss_address_tp,
                                 vI.ats_ss_address,
                                 vI.ats_tarif_sum,
                                 vI.ats_act_sum,
                                 vI.ats_rnspa,
                                 'A',
                                 'P');
                END LOOP;
            END IF;

            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);

            -- #115466
            UPDATE at_service t
               SET (t.ats_ss_term) =
                       (SELECT MAX (s.ats_ss_term)
                          FROM at_service s
                         WHERE     s.ats_at = p_at_id
                               AND s.ats_nst = t.ats_nst
                               AND s.history_status = 'A')
             WHERE t.ats_at = rec.decision_id;
        END LOOP;
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- В СТАН "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Canceled');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину скасування');
        END IF;

        Cmes$act.Check_Act_Access_Cm (p_At_Id);

        Api$act.Set_At_St (
            p_At_Id          => p_At_Id,
            p_At_St_Old      => 'XN',
            p_At_St_New      => 'XD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД Акт про надання повнолітній особі соціальних послуг екстрено (кризово)
    -- В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_At_St   VARCHAR2 (10);
    BEGIN
        Write_Audit ('Set_Declined');

        IF p_Reason IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не вказано причину відхилення');
        END IF;

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;
        l_At_St := Api$act.Get_At_St (p_At_Id);

        IF    --Якщо стан акту "Очікує підписання" - дозволяемо змінювати стан, лише якщо поточний користувач є серед підписантів
              (    l_At_St = 'XV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'XS'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'XR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'XR',
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;

    -----------------------------------------------------------
    --         ПЕРЕНАЗНАЧЕННЯ АКТУ НА ІНШОГО КЕЙС МЕНЕДЖЕРА
    -----------------------------------------------------------
    PROCEDURE Change_Act_Cm (p_At_Id IN NUMBER, p_New_Cu_Id IN NUMBER --Ід користувача КМа, на якого переназначається акт
                                                                     )
    IS
        l_At_St       VARCHAR2 (10);
        l_At_Rnspm    NUMBER;
        l_Old_Cu_Id   NUMBER;
    BEGIN
        --Raise_Application_Error(-20000, 'deprecated');
        Write_Audit ('Change_Act_Cm');

        SELECT a.At_Rnspm, a.At_Cu
          INTO l_At_Rnspm, l_Old_Cu_Id
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        --Дозволяємо виконання операції лише для користувача надавача за яким закріплено акт
        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id)
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

           UPDATE Act a
              SET a.At_Cu = p_New_Cu_Id
            WHERE a.At_Id = p_At_Id
        RETURNING a.At_St
             INTO l_At_St;

        Api$act.Write_At_Log (
            p_Atl_At        => p_At_Id,
            p_Atl_Hs        => Tools.Gethistsessioncmes (),
            p_Atl_St        => l_At_St,
            p_Atl_Message   =>
                   CHR (38)
                || '233#'
                || Ikis_Rbm.Tools.Getcupib (l_Old_Cu_Id)
                || '#'
                || Ikis_Rbm.Tools.Getcupib (p_New_Cu_Id),
            p_Atl_St_Old    => NULL);
    END;

    PROCEDURE Lock_Act_Form_Nowait (p_Atd_Id IN NUMBER)
    IS
    BEGIN
        Api$act.Lock_Act_Form_Nowait (p_Atd_Id);
    END;

    -----------------------------------------------------------
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ НА ЗРІЗ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER)
    IS
    BEGIN
        Write_Audit ('Set_Atd_Dh');
        Api$act.Set_Atd_Dh (p_Atd_Id, p_Atd_Dh);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    -----------------------------------------------------------
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');
        RETURN Cmes$act.Check_File_Access (p_File_Code   => p_File_Code,
                                           p_Cmes_Id     => p_Cmes_Id);
    END;

    --------------------------------------------------------------
    --   Встановлення кейс менеджера який буде вести випадок
    --------------------------------------------------------------
    PROCEDURE Set_Cm (p_At_Id IN NUMBER,                          --Ід ріщення
                                         p_At_Cu IN NUMBER --Ід користувача КМа, який буде вести випадок
                                                          )
    IS
        l_At_Main_Link   NUMBER;
    BEGIN
        SELECT a.at_main_link
          INTO l_At_Main_Link
          FROM Act a
         WHERE a.At_Id = p_At_Id;

        IF l_At_Main_Link IS NOT NULL
        THEN
            CMES$ACT_PDSP.Set_Cm (l_At_Main_Link, p_At_Cu);
        ELSE
            CMES$ACT.Set_Cm_Execute (p_At_Id, p_At_Cu);
        END IF;
    END;
END Cmes$act_Anpoe;
/