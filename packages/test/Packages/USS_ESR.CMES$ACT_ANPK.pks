/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_ANPK
IS
    -- Author  : AKOMISAROV
    -- Created : 11.11.2023 14:31:25
    -- Purpose : Акт з надання соціальної послуги кризового та екстреного втручання

    Pkg                    VARCHAR2 (50) := 'CMES$ACT_ANPK';

    с_Form_Ndt   CONSTANT NUMBER := 841;


    TYPE r_Act_Anpk IS RECORD
    (
        At_Pc                 Act.At_Pc%TYPE,
        At_Dt                 TIMESTAMP,
        At_Org                Act.At_Org%TYPE,
        At_Sc                 Act.At_Sc%TYPE,
        At_Rnspm              Act.At_Rnspm%TYPE,
        At_Ap                 Act.At_Ap%TYPE,
        At_Action_Start_Dt    TIMESTAMP,
        At_Action_Stop_Dt     TIMESTAMP,
        At_Notes              Act.At_Notes%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Decision           NUMBER
    );

    --==============================================================--
    --      ЗБЕРЕЖЕННЯ "Акт з надання соціальної послуги кризового та екстреного втручання"
    --==============================================================--
    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Other_Spec        IN     CLOB,
                        p_At_Signers           IN     CLOB);


    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Ip_Cur           OUT SYS_REFCURSOR,
                            p_Spec_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,
                           p_At_Dt_Stop     IN     DATE,
                           p_At_Num         IN     VARCHAR2,
                           p_At_St          IN     VARCHAR2,
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Res               OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Rc (p_Res OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR);

    --==============================================================--
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --==============================================================--
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    --==============================================================--
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ (з кодами підписів через кому)
    --==============================================================--
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    --==============================================================--
    --     ФОРМУВАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --==============================================================--
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    --==============================================================--
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    --==============================================================--
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    --==============================================================--
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
END Cmes$act_Anpk;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPK TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ANPK TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:19 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_ANPK
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Anpk
    IS
        l_Result   r_Act_Anpk;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Anpk', TRUE)
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

    --==============================================================--
    --      ЗБЕРЕЖЕННЯ "Акт з надання соціальної послуги кризового та екстреного втручання"
    --==============================================================--
    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Other_Spec        IN     CLOB,
                        p_At_Signers           IN     CLOB)
    IS
        l_Cu_Id             NUMBER;
        l_Act               r_Act_Anpk;
        l_Lock              Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_At_Cu             NUMBER;
        l_At_St_Old         VARCHAR2 (10);
        l_Persons           Api$act.t_At_Persons;
        l_Signers           Api$act.t_At_Signers;
        l_Individual_Plan   Api$act.t_At_Individual_Plan;
        l_Other_Spec        Api$act.t_At_Other_Spec;

        --------------------------------------------------------------------
        PROCEDURE Save_Service (p_At_Id IN NUMBER, p_At_Nst IN NUMBER)
        IS
            l_Ats_Id   NUMBER;
        BEGIN
            SELECT MAX (Ats_Id)
              INTO l_Ats_Id
              FROM At_Service s
             WHERE s.Ats_At = p_At_Id AND s.History_Status = 'A';

            IF l_Ats_Id IS NULL
            THEN
                INSERT INTO At_Service (Ats_Id,
                                        Ats_At,
                                        Ats_Nst,
                                        History_Status,
                                        Ats_St)
                     VALUES (0,
                             p_At_Id,
                             p_At_Nst,
                             'A',
                             'R');
            ELSE
                UPDATE At_Service s
                   SET s.Ats_Nst = p_At_Nst
                 WHERE s.Ats_Id = l_Ats_Id;
            END IF;
        END;
    --------------------------------------------------------------------
    BEGIN
        Write_Audit ('Save_Act');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        l_Act := Parse_Act (p_Act);

        IF     l_Act.At_Rnspm IS NOT NULL
           AND NOT Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => l_Act.At_Rnspm,
                       p_Cr_Code         => 'NSP_CM')
        THEN
            Raise_Application_Error (-20000, 'Некоректно вакзано надавача');
        END IF;

        IF     l_Act.At_Decision IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Decision)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано рішення по іншому надавачу');
        END IF;

        --Редагування
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

            IF NVL (l_At_St_Old, '-') <> 'GN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування "Акт з надання соціальної послуги кризового" в поточному статусі заборонено');
            END IF;
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Individual_Plan :=
            Api$act.Parse_Individual_Plan (p_At_Individual_Plan);
        l_Other_Spec := Api$act.Parse_Other_Spec (p_At_Other_Spec);

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (p_At_Id                => p_At_Id,
                          p_At_Tp                => 'ANPK',
                          p_At_Pc                => l_Act.At_Pc,
                          p_At_Num               => NULL,
                          p_At_Dt                => l_Act.At_Dt,
                          p_At_Org               => l_Act.At_Org,
                          p_At_Sc                => l_Act.At_Sc,
                          p_At_Rnspm             => l_Act.At_Rnspm,
                          p_At_Rnp               => NULL,
                          p_At_Ap                => l_Act.At_Ap,
                          p_At_St                => 'GN',
                          p_At_Src               => p_At_Src,
                          p_At_Main_Link_Tp      => 'DECISION',
                          p_At_Main_Link         => l_Act.At_Decision,
                          p_At_Action_Start_Dt   => l_Act.At_Action_Start_Dt,
                          p_At_Action_Stop_Dt    => l_Act.At_Action_Stop_Dt,
                          p_At_Notes             => l_Act.At_Notes,
                          p_At_Live_Address      => l_Act.At_Live_Address,
                          p_At_Cu                => l_Cu_Id,
                          p_New_Id               => p_At_Id);

        Save_Service (p_At_Id, 420);
        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);
        Api$act.Save_Individual_Plans (
            p_At_Id              => p_At_Id,
            p_Individual_Plans   => l_Individual_Plan);
        Api$act.Map_Atop_Atip (p_Other_Specs        => l_Other_Spec,
                               p_Individual_Plans   => l_Individual_Plan);
        Api$act.Save_Other_Specs (p_At_Id         => p_At_Id,
                                  p_Other_Specs   => l_Other_Spec);

        IF l_Act.At_Decision IS NOT NULL
        THEN
            Api$act.Save_Link (p_Atk_At        => p_At_Id,
                               p_Atk_Link_At   => l_Act.At_Decision,
                               p_Atk_Tp        => 'DECISION');
        END IF;

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (p_at_id => p_At_Id, p_ndt_id => с_Form_Ndt);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'GN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);

        Tools.Release_Lock (l_Lock);
    END;

    --==============================================================--
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    --==============================================================--
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Anpk_St s ON a.At_St = s.Dic_Value
             WHERE a.At_Id = p_At_Id;
    END;

    --==============================================================--
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    --==============================================================--
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
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
                   api$act.Get_Atd_Attach_Source (a.at_id, с_Form_Ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Anpk_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id;
    END;

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    --==============================================================--
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,
                           p_At_Dt_Stop     IN     DATE,
                           p_At_Num         IN     VARCHAR2,
                           p_At_St          IN     VARCHAR2,
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Res               OUT SYS_REFCURSOR)
    IS
        l_Cu_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Cm');
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPK'
                   AND (a.At_Cu = l_Cu_Id)
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap);

        Get_Act_List (p_Res);
    END;

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ ОТРИМУВАЧА
    --==============================================================--
    PROCEDURE Get_Acts_Rc (p_Res OUT SYS_REFCURSOR)
    IS
        l_Cu_Sc   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_Rc');
        l_Cu_Sc := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, де поточний користувач є серед підписантів,
        --та які хоч раз переводились до стану "Очікує підписання"
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPK'
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

    --==============================================================--
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІ ДЛЯ НАДАВАЧА
    --==============================================================--
    PROCEDURE Get_Acts_Pr (p_At_Dt_Start     IN     DATE,
                           p_At_Dt_Stop      IN     DATE,
                           p_At_Num          IN     VARCHAR2,
                           p_At_St           IN     VARCHAR2,
                           p_Cmes_Owner_Id   IN     NUMBER,
                           p_Res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_Pr');

        IF NOT Ikis_Rbm.Api$cmes_Auth.Is_Roles_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Codes        => 'NSP_SPEC,NSP_ADM')
        THEN
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'ANPK'
                   AND a.At_Rnspm = p_Cmes_Owner_Id
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND a.At_Num LIKE p_At_Num || '%'
                   AND (p_At_St IS NULL OR a.At_St = p_At_St);

        Get_Act_List (p_Res);
    END;

    --==============================================================--
    --    ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ПО ЗВЕРНЕННЮ
    --==============================================================--
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

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
                       AND a.At_Tp = 'ANPK'
                       AND a.At_Rnspm = p_Cmes_Owner_Id;
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Ap = p_Ap_Id
                       AND a.At_Tp = 'ANPK'
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
                                 WHERE l.Atl_At = a.At_Id AND l.Atl_St = 'GV');
        END IF;

        Get_Act_List (p_Acts);
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
    --     ОТРИМАННЯ ІНДИВІДУАЛЬНИХ ПДЛАНІВ
    -----------------------------------------------------------
    PROCEDURE Get_Indivilual_Plan (p_At_Id   IN     NUMBER,
                                   p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        --TODO: move to api$act?
        OPEN p_Res FOR
            SELECT p.*,
                   t.Nst_Name      AS Atip_Nst_Name,
                   a.Nsa_Name      AS Atip_Nsa_Name,
                   d.Nsa_Name      AS Atip_Nsa_Det_Name,
                   Pr.Dic_Name     AS Atip_Period_Name
              FROM At_Individual_Plan  p
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON p.Atip_Nst = t.Nst_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Nst_Activities a
                       ON p.Atip_Nsa = a.Nsa_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Nst_Activities d
                       ON p.Atip_Nsa_Det = d.Nsa_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Atip_Period Pr
                       ON p.Atip_Period = Pr.Dic_Value
             WHERE p.Atip_At = p_At_Id AND p.History_Status = 'A';
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
                   JOIN Uss_Ndi.v_Ddn_Atop_Ip_Tp t ON s.Atop_Tp = t.Dic_Value
             WHERE s.Atop_At = p_At_Id AND s.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ "Акт з надання соціальної послуги кризового та екстреного втручання"
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id         IN     NUMBER,
                            p_Act_Cur          OUT SYS_REFCURSOR,
                            p_Pers_Cur         OUT SYS_REFCURSOR,
                            p_Ip_Cur           OUT SYS_REFCURSOR,
                            p_Spec_Cur         OUT SYS_REFCURSOR,
                            p_Signers_Cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Get_Indivilual_Plan (p_At_Id, p_Ip_Cur);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
    END;

    --==============================================================--
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --==============================================================--
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

    --==============================================================--
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ (з кодами підписів через кому)
    --==============================================================--
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

    --==============================================================--
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --==============================================================--
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
        l_build   VARCHAR2 (1000);
        l_ndt     NUMBER;
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        l_ndt := Api$act.Define_Print_Form_Ndt (p_At_Id, l_build);

        --Raise_Application_Error(-20000, 'Заглушка, поки немає "ДРУКОВАНА ФОРМА АКТУ"');

        Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                               p_At_Prj_St         => 'GN',
                               p_Form_Ndt          => l_ndt,
                               p_Form_Build_Proc   => l_build,
                               p_Doc_Cur           => p_Doc_Cur);
    END;

    --==============================================================--
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    --==============================================================--
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => с_Form_Ndt,
                              p_Doc       => p_Doc);
    END;


    /*
    3) КМ:
    - створює проєкт Акту, заповнює необхідні дані, зберігає їх – статус GN
    - КМ створює друковану форму Акту та підписує її – статус DV, рішення відображається в кабінеті ОСП
    4) ОСП:
    - відхиляє Акт – статус GR, КМ має створити новий Акт
    або
    - підписує його – статус GS, рішення відображається в кабінеті НСП
    5) НСП:
    - відхиляє Акт – статус GR, КМ має створити новий Акт
    або
    - підписує його – статус GP = точка виходу з міні-ЖЦ – в залежності від встановлених в ANPK ознак, глобальний ЖЦ має піти відповідною гілкою
    */

    --==============================================================--
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ "Акт з надання соціальної послуги кризового та екстреного втручання" КМом
    --==============================================================--
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        l_st   VARCHAR2 (10) := 'GV';
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
                                    'GS',
                                    с_Form_Ndt,
                                    l_st);
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'GN',
                p_At_St_New   => l_st,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    --==============================================================--
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ "Акт з надання соціальної послуги кризового та екстреного втручання" ОТРИМУВАЧЕМ
    --==============================================================--
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
                p_At_St_Old   => 'GV',
                p_At_St_New   => 'GS',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    --==============================================================--
    -- ЗБЕРЕЖЕННЯ ІНФОРМАЦІЇ ЩОДО ПІДПИСАННЯ "Акт з надання соціальної послуги кризового та екстреного втручання" НАДАВАЧЕМ
    --==============================================================--
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => с_Form_Ndt,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'GS',
            p_At_St_New   => 'GP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        --Для всіх рішень по зверненню до якого привязаний акт
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St IN ('SP1', 'SU')
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);
        END LOOP;
    END;

    --==============================================================--
    -- ПЕРЕВОД АКТУ "Акт з надання соціальної послуги кризового та екстреного втручання"
    -- В СТАН  "СКАСОВАНО"
    --==============================================================--
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
            p_At_St_Old      => 'GN',
            p_At_St_New      => 'GD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    --==============================================================--
    -- ПЕРЕВОД АКТУ "Акт з надання соціальної послуги кризового та екстреного втручання"
    -- В СТАН "ВІДХИЛЕНО"
    --==============================================================--
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
              (    l_At_St = 'GV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'GS'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'GR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'GR',
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;

    --==============================================================--
    --         ПЕРЕНАЗНАЧЕННЯ АКТУ НА ІНШОГО КЕЙС МЕНЕДЖЕРА
    --==============================================================--
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

    --==============================================================--
    --         ЗБЕРЕЖЕННЯ ПОСИЛАННЯ НА ЗРІЗ ДОКУМЕНТА
    --==============================================================--
    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER)
    IS
    BEGIN
        Write_Audit ('Set_Atd_Dh');
        Api$act.Set_Atd_Dh (p_Atd_Id, p_Atd_Dh);
    END;

    --==============================================================--
    --     ПЕРЕВІРКА НАЯВНОСТІ ДОСТУПУ ДО ФАЙЛУ
    --==============================================================--
    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2
    IS
    BEGIN
        Write_Audit ('Check_File_Access');
        RETURN Cmes$act.Check_File_Access (p_File_Code   => p_File_Code,
                                           p_Cmes_Id     => p_Cmes_Id);
    END;
END Cmes$act_Anpk;
/