/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_APOP
IS
    -- Author  : SHOSTAK
    -- Created : 16.06.2023 4:31:25 PM
    -- Purpose : Робота з актом первинної оцінки потреб

    Pkg                    VARCHAR2 (50) := 'CMES$ACT_APOP';

    с_Form_Ndt   CONSTANT NUMBER := 804;


    TYPE r_Act_Apop IS RECORD
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

    PROCEDURE Save_Act (p_At_Id           IN OUT NUMBER,
                        p_At_Src          IN     VARCHAR2,
                        p_Act             IN     CLOB,
                        p_At_Persons      IN     CLOB,
                        p_At_Sections     IN     CLOB,
                        p_At_Signers      IN     CLOB,
                        p_At_Services     IN     CLOB,
                        p_At_Other_Spec   IN     CLOB);

    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Services_Cur       OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR);

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

    PROCEDURE Get_Acts_Rc (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_At_Case_Class   IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

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

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

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

    PROCEDURE Copy_Act (p_At_id       IN     Act.At_Id%TYPE,
                        p_New_At_Id      OUT Act.At_Id%TYPE);
END Cmes$act_Apop;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_APOP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_APOP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_APOP TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_APOP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:19 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_APOP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Apop
    IS
        l_Result   r_Act_Apop;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Apop', TRUE)
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
    --        ЗБЕРЕЖЕННЯ АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id           IN OUT NUMBER,
                        p_At_Src          IN     VARCHAR2,
                        p_Act             IN     CLOB,
                        p_At_Persons      IN     CLOB,
                        p_At_Sections     IN     CLOB,
                        p_At_Signers      IN     CLOB,
                        p_At_Services     IN     CLOB,
                        p_At_Other_Spec   IN     CLOB)
    IS
        l_Cu_Id           NUMBER;
        l_At_Cu           NUMBER;
        l_At_St_Old       VARCHAR2 (10);
        l_Already_Exist   NUMBER;
        l_At_Id           NUMBER := p_At_Id;
        l_Act             r_Act_Apop;
        l_Persons         Api$act.t_At_Persons;
        l_Sections        Api$act.t_At_Sections;
        l_Signers         Api$act.t_At_Signers;
        l_Services        Api$act.t_At_Services;
        l_Other_Spec      Api$act.t_At_Other_Spec;
        l_is_ap_correct   NUMBER;
    BEGIN
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

            IF NVL (l_At_St_Old, '-') <> 'AN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування акту в поточному статусі заборонено');
            END IF;
        END IF;

        SELECT SIGN (COUNT (*))
          INTO l_Already_Exist
          FROM Act a
         WHERE     a.At_Tp = 'APOP'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('AR', 'AD')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Already_Exist = 1
        THEN
            Raise_Application_Error (
                -20000,
                'По цьому випадку вже існує акт первинної оцінки потреб');
        END IF;

        --#103625
        IF    API$APPEAL.Get_Ap_Attr_Str (p_Ap_Id     => l_Act.At_Ap,
                                          p_Nda_Id    => 1870,
                                          p_Default   => 'F') =
              'T'
           OR API$APPEAL.Get_Ap_Attr_Str (p_Ap_Id     => l_Act.At_Ap,
                                          p_Nda_Id    => 1947,
                                          p_Default   => 'F') =
              'T'
           OR API$APPEAL.Get_Ap_Attr_Str (p_Ap_Id     => l_Act.At_Ap,
                                          p_Nda_Id    => 8263,
                                          p_Default   => 'F') =
              'T'
        THEN
            l_Act.At_Case_Class := 'EM';
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Sections := Api$act.Parse_Sections (p_At_Sections);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Services := Api$act.Parse_Services (p_At_Services);
        l_Other_Spec := Api$act.Parse_Other_Spec (p_At_Other_Spec);


        --#112295
        SELECT COUNT (1), NVL (MAX (at_sc), l_Act.At_Sc)
          INTO l_is_ap_correct, l_Act.At_Sc
          FROM act
         WHERE     at_id = l_Act.At_Decision
               AND EXISTS
                       (SELECT 1
                          FROM at_log
                         WHERE atl_at = at_id AND atl_st = 'SP1');

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);


        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'APOP',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Ap               => l_Act.At_Ap,
            p_At_St               => 'AN',
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

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_APOP.SAVE_ACT',
            p_obj_tp   => 'APOP',
            p_obj_id   => p_At_Id,
            p_regular_params   =>
                   'p_Cu_Id='
                || Ikis_Rbm.Tools.Getcurrentcu
                || ', l_At_Id='
                || l_At_Id
                || ', l_Act.At_Sc='
                || l_Act.At_Sc,
            p_lob_param   =>
                tools.GetStartPackageName (DBMS_UTILITY.FORMAT_CALL_STACK ()));

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);

        --#108427
        l_is_ap_correct := API$APPEAL.Is_Appeal_Maked_Correct (l_Act.At_Ap);

        IF l_is_ap_correct > 0 AND l_Act.At_Decision IS NOT NULL
        THEN
            IF CMES$ACT.Compare_Atp_App_Tp (p_At_Id, l_Act.At_Decision) > 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'Заборонено змінювати тип участника');
            END IF;
        END IF;

        --#110355
        Api$act.Check_Atp_Z_Exists_Incorrect (p_At_Id);


        Api$act.Save_Sections (p_At_Id      => p_At_Id,
                               p_Sections   => l_Sections,
                               p_Persons    => l_Persons);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);
        Api$act.Save_Services (p_At_Id => p_At_Id, p_Services => l_Services);
        Api$act.Save_Other_Specs (p_At_Id         => p_At_Id,
                                  p_Other_Specs   => l_Other_Spec);

        Api$act.Check_At_Services (p_At_Id => p_At_Id);

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (p_at_id => p_At_Id, p_ndt_id => с_Form_Ndt);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'AN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.at_sc)
                       AS At_Sc_Pib,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source,
                   --#113718
                    (SELECT atp_pib
                       FROM (  SELECT    p.atp_ln
                                      || ' '
                                      || p.atp_fn
                                      || ' '
                                      || p.atp_mn    atp_pib
                                 FROM at_person p
                                WHERE atp_at = a.at_id AND history_Status = 'A'
                             ORDER BY CASE
                                          WHEN atp_app_tp = 'OS' THEN 1
                                          WHEN atp_app_tp = 'Z' THEN 2
                                          WHEN atp_app_tp = 'AP' THEN 3
                                          ELSE 4
                                      END,
                                      atp_id)
                      WHERE ROWNUM = 1)
                       AS act_main_pib,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Apop_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
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
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Cc.Dic_Name
                       AS At_Case_Class_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   API$APPEAL.Is_Appeal_Maked_Correct (at_ap)
                       AS Is_Appeal_Maked_Correct,
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Apop_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value;
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
            p_src      => 'USS_ESR.CMES$ACT_APOP.Get_Acts_Cm',
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
                || ' p_Ap_Is_Correct='
                || p_Ap_Is_Correct);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'APOP'
                   AND (a.At_Cu = l_Cu_Id)
                   --region #111777 111516
                   AND CASE
                           WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                        a.at_ap) =
                                    0
                                AND EXISTS
                                        (SELECT 1
                                           FROM at_log
                                          WHERE     atl_at = a.at_id
                                                AND atl_st = 'AS')
                                AND (   (    EXISTS
                                                 (SELECT 1
                                                    FROM at_section_feature
                                                         atf
                                                   WHERE     atf.atef_at =
                                                             a.at_id
                                                         AND atf.atef_nda IN
                                                                 (843)
                                                         AND atf.atef_feature =
                                                             'T')
                                         AND a.at_conclusion_tp = 'V2')
                                     OR (    EXISTS
                                                 (SELECT 1
                                                    FROM at_section_feature
                                                         atf
                                                   WHERE     atf.atef_at =
                                                             a.at_id
                                                         AND atf.atef_nda IN
                                                                 (2062)
                                                         AND atf.atef_feature =
                                                             'T')
                                         AND a.at_conclusion_tp = 'V1'))
                           THEN
                               0
                           WHEN     API$APPEAL.Is_Appeal_Maked_Correct (
                                        a.at_ap) =
                                    1
                                AND NOT EXISTS
                                        (SELECT 1
                                           FROM at_log
                                          WHERE     atl_at = a.at_main_link
                                                AND atl_st = 'SD')
                           THEN
                               1
                           ELSE
                               1
                       END =
                       1
                   --end region #111777

                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND NVL (a.At_Case_Class, '-') =
                       NVL (p_At_Case_Class, NVL (a.At_Case_Class, '-'))
                   --AND a.At_Main_Link = Nvl(p_At_Main_Link, a.At_Main_Link)
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link =
                           NVL (p_At_Main_Link, a.At_Main_Link))
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

        Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_APOP.Get_Acts_Rc',
                   p_obj_tp           => 'CMES_CU_SC',
                   p_obj_id           => l_Cu_Sc,
                   p_regular_params   => '');

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, де поточний користувач є серед підписантів,
        --та які хоч раз переводились до стану "Очікує підписання"
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'APOP'
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
                             WHERE     l.Atl_At = a.At_Id
                                   AND l.Atl_St IN ('AV', 'AK'));

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
                           p_Res                OUT SYS_REFCURSOR,
                           p_Ap_Is_Correct   IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');
        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_APOP.Get_Acts_Pr',
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
                || ' p_Ap_Is_Correct='
                || p_Ap_Is_Correct);

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_APOP.Get_Acts_Pr',
                       p_obj_tp           => 'CMES_OWNER_ID',
                       p_obj_id           => p_Cmes_Owner_Id,
                       p_regular_params   => 'Insufficient privileges.');
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'APOP'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (   p_At_Case_Class IS NULL
                        OR a.At_Case_Class = p_At_Case_Class)
                   AND (   p_Ap_Is_Correct IS NULL
                        OR API$APPEAL.Is_Appeal_Maked_Correct (at_ap) =
                           p_Ap_Is_Correct);

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
            p_src      => 'USS_ESR.CMES$ACT_APOP.Get_Acts_By_Ap',
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
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'AR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'APOP'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'AD')
                 WHERE Rn = 1;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'AR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'APOP'
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'AD'
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
                                               AND l.Atl_St IN ('AV', 'AK')))
                 WHERE Rn = 1;
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_APOP.Get_Acts_By_Ap',
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
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ ЗАЛУЧЕНИХ СПЕЦІАЛІСТІВ
    -----------------------------------------------------------
    PROCEDURE Get_Other_Spec (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT s.*, t.Dic_Name AS Atop_Tp_Name
              FROM At_Other_Spec  s
                   JOIN Uss_Ndi.v_Ddn_Atop_Apop_Tp t
                       ON s.Atop_Tp = t.Dic_Value
             WHERE s.Atop_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Services_Cur       OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_Apop.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => NULL);

        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'APOP');


        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
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
        l_Form_Build_Proc   VARCHAR2 (500);
    BEGIN
        Write_Audit ('Get_Form_File');

        -- Check_Act_Access(p_At_Id);

        SELECT CASE
                   WHEN at_conclusion_tp = 'V1'
                   THEN
                       'uss_esr.Api$act_Rpt.Build_Act_Needs_Assessment'
                   ELSE
                       'uss_esr.Api$act_Rpt.Build_Act_Needs_Assessment_S2'
               END
          INTO l_Form_Build_Proc
          FROM act
         WHERE at_id = p_At_Id;

        Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                               p_At_Prj_St         => 'AN',
                               p_Form_Ndt          => с_Form_Ndt,
                               p_Form_Build_Proc   => l_Form_Build_Proc, --'Api$Act_Rpt.BUILD_ACT_NEEDS_ASSESSMENT_S2',
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

    -----------------------------------------------------------
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
    BEGIN
        Api$act.Get_Form_Doc_Src (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => с_Form_Ndt,
                                  p_Doc_Src   => p_Doc_Src);
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ ПЕРИВОННОЇ
    -- ОЦІНКИ ПОТРЕБ КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        --l_doc_Attach_Src VARCHAR2(10);
        l_st   VARCHAR2 (10) := 'AV';
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            /*Get_Form_Doc_Src(p_at_id, l_doc_Attach_Src);
            IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T') THEN
              l_st := 'AK';
              Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id, p_Ndt_Id => с_Form_Ndt);
            ELSIF (l_doc_Attach_Src = 'TABLET' AND l_is_used = 'T' AND Api$act.Is_All_Signed(p_At_Id => p_At_Id, p_Ati_Tp => 'RC')) THEN
              l_st := 'AK';
            END IF;*/
            api$act.Handle_Cm_Sign (p_at_id,
                                    l_st,
                                    'AK',
                                    с_Form_Ndt,
                                    l_st);
            --raise_application_error(-20000, l_st);
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'AN',
                p_At_St_New   => l_st                                 /*'AV'*/
                                     ,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ ПЕРИВОННОЇ
    -- ОЦІНКИ ПОТРЕБ ОТРИМУВАЧЕМ
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
                p_At_St_Old   => 'AV',
                p_At_St_New   => 'AK',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ АКТУ ПЕРИВОННОЇ
    -- ОЦІНКИ ПОТРЕБ НАДАВАЧЕМ
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_is_ap_correct   NUMBER;
        l_is_no_service   VARCHAR2 (10) := 'F';
        l_at_ap           NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'AK',
            p_At_St_New   => 'AS',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        SELECT at_ap
          INTO l_at_ap
          FROM act
         WHERE at_id = p_At_Id;

        --#111896
        l_is_ap_correct := API$APPEAL.Is_Appeal_Maked_Correct (l_At_Ap);

        IF l_is_ap_correct = 0
        THEN
            SELECT CASE
                       WHEN    (    Api$act.Get_Full_Attr_Val_Str (
                                        apop.at_id,
                                        843) =
                                    'T'
                                AND AT_CONCLUSION_TP = 'V2')
                            OR (    Api$act.Get_Full_Attr_Val_Str (
                                        apop.at_id,
                                        2062) =
                                    'T'
                                AND AT_CONCLUSION_TP = 'V1')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END    res
              INTO l_is_no_service
              FROM act apop
             WHERE apop.at_id = p_At_Id;

            IF l_is_no_service = 'T'
            THEN
                Api$appeal.Move_Appeal_To_Status (l_at_ap, 'V');
            END IF;
        END IF;

        --Для всіх рішень по зверненню до якого привязаний акт
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St IN ('SP1', 'SNR')
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);
        END LOOP;
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ В СТАН
    -- "СКАСОВАНО"
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
            p_At_St_Old      => 'AN',
            p_At_St_New      => 'AD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ В СТАН
    -- "ВІДХИЛЕНО"
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
              (    l_At_St = 'AV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'AK'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'AR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'AR',
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
        l_At_St      VARCHAR2 (10);
        l_At_Rnspm   NUMBER;
        l_At_Cu      NUMBER;
    BEGIN
        Write_Audit ('Set_Cm');

        SELECT a.At_Rnspm, a.At_Cu, a.At_St
          INTO l_At_Rnspm, l_At_Cu, l_At_St
          FROM Act a
         WHERE a.At_Id = p_At_Id AND a.At_Tp = 'APOP';

        IF l_At_Cu = p_At_Cu
        THEN
            RETURN;
        END IF;

        IF l_At_St NOT IN ('AN')
        THEN
            Raise_Application_Error (
                -20000,
                'Зміна кейс-менеджера в поточному стані рішення заборонена');
        END IF;

        /*
        --Дозволяємо виконання операції лише для користувача надавача за яким закріплено акт
        IF NOT CMES$ACT_PDSP.Is_Role_Assigned(p_Cmes_Owner_Id => l_At_Rnspm, p_Role => 'NSP_SPEC') THEN
          Api$act.Raise_Unauthorized;
        END IF;

        IF NOT CMES$ACT_PDSP.Is_Role_Assigned(p_Cu_Id => p_At_Cu, p_Cmes_Owner_Id => l_At_Rnspm, p_Role => 'NSP_CM') THEN
          Raise_Application_Error(-20000,
                                  'Обраний кейс-менеджер не закріплений за поточним надавачем');
        END IF;
         */
        CMES$ACT.Set_Cm_Execute (p_At_Id, p_At_Cu);
    END;

    PROCEDURE Copy_Act (p_At_id       IN     Act.At_Id%TYPE,
                        p_New_At_Id      OUT Act.At_Id%TYPE)
    IS
        l_At   Act%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_At
          FROM Act
         WHERE at_tp = 'APOP' AND at_id = p_At_id AND at_st = 'AS';

        Api$act.Copy_At_To_New (p_At_id       => p_At_id,
                                p_New_At_Tp   => 'APOP',
                                p_New_At_Id   => p_New_At_Id);

        UPDATE Act
           SET At_st = 'AA'
         WHERE At_id = p_At_id;

        UPDATE Act
           SET At_main_link = p_At_Id,
               At_main_link_tp = NULL,
               at_action_start_dt = SYSDATE,
               at_action_stop_dt =
                     SYSDATE
                   + (l_At.At_Action_Stop_Dt - l_At.At_Action_Start_Dt)
         WHERE At_id = p_New_At_Id;
    END;
END Cmes$act_Apop;
/