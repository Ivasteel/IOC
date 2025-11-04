/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_AVOP
IS
    -- Author  : OLEKSII
    -- Created : 16.08.2023
    -- Purpose : Робота з актом вторинної оцінки потреб

    Pkg   VARCHAR2 (50) := 'CMES$ACT_AVOP';

    TYPE r_Act_Avop IS RECORD
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
        At_Case_Class         Act.At_Case_Class%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Conclusion_Tp      Act.At_Conclusion_Tp%TYPE,
        At_Decision           NUMBER,
        At_Nst                NUMBER,
        At_Ndt                NUMBER
    );

    PROCEDURE Save_Act (p_At_Id                  IN OUT NUMBER,
                        p_At_Src                 IN     VARCHAR2,
                        p_Act                    IN     CLOB,
                        p_At_Persons             IN     CLOB,
                        p_At_Sections            IN     CLOB,
                        p_At_Signers             IN     CLOB,
                        p_At_Living_Conditions   IN     CLOB,
                        p_At_Other_Spec          IN     CLOB,
                        p_At_Documents           IN     CLOB);

    FUNCTION Define_Print_Form_Ndt (p_At_Id IN NUMBER)
        RETURN NUMBER;


    --=========================================================--
    --     Отримання даних акту ВТОРИННОЇ оцінки потреб
    --=========================================================--
    PROCEDURE Get_Act_Card (p_At_Id               IN     NUMBER,
                            p_Act_Cur                OUT SYS_REFCURSOR,
                            p_Pers_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur            OUT SYS_REFCURSOR,
                            p_Living_Conditions      OUT SYS_REFCURSOR,
                            p_Spec_Cur               OUT SYS_REFCURSOR,
                            p_Docs_Cur               OUT SYS_REFCURSOR,
                            p_Files_Cur              OUT SYS_REFCURSOR,
                            p_Attrs_Cur              OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id               IN     NUMBER,
                            p_Act_Cur                OUT SYS_REFCURSOR,
                            p_Pers_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur            OUT SYS_REFCURSOR,
                            p_Living_Conditions      OUT SYS_REFCURSOR,
                            p_Spec_Cur               OUT SYS_REFCURSOR,
                            p_Docs_Cur               OUT SYS_REFCURSOR,
                            p_Files_Cur              OUT SYS_REFCURSOR);


    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті НСП
    --=========================================================--
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,   --Дата реєстрації з
                           p_At_Dt_Stop     IN     DATE,  --Дата реєстрації по
                           p_At_Num         IN     VARCHAR2,           --Номер
                           --p_At_Spec_Name IN VARCHAR2, --ПІБ кейс- менеджера, яким сформовано форму оцінювання
                           --p_At_Src IN VARCHAR2, --Джерело
                           p_At_St          IN     VARCHAR2, --Наявність документів на підпис затвердження
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Res               OUT SYS_REFCURSOR);

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

    PROCEDURE Set_Atd_Dh (p_Atd_Id IN NUMBER, p_Atd_Dh IN NUMBER);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМа
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ ПЕРВИННОЇ ОЦІНКИ ПОТРЕБ В СТАН
    -- "СКАСОВАНО"
    -----------------------------------------------------------
    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "ВІДХИЛЕНО"
    -----------------------------------------------------------
    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Avop;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_AVOP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_AVOP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_AVOP TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_AVOP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_AVOP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    --=========================================================--
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
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

    --=========================================================--
    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act_Avop
    IS
        l_Result   r_Act_Avop;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act_Avop', TRUE)
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

    PROCEDURE Save_Service (p_At_Id IN NUMBER, p_At_Nst IN NUMBER)
    IS
        l_Ats_Id    NUMBER;
        l_ss_term   VARCHAR2 (10);
    BEGIN
        SELECT MAX (Ats_Id)
          INTO l_Ats_Id
          FROM At_Service s
         WHERE s.Ats_At = p_At_Id AND s.History_Status = 'A';

        SELECT MAX (s.ats_ss_term)
          INTO l_ss_term
          FROM act  t
               JOIN act p ON (p.at_id = t.at_main_link)
               JOIN at_service s ON (s.ats_at = p.at_id)
         WHERE     t.at_id = p_At_Id
               AND s.ats_nst = p_At_Nst
               AND s.history_status = 'A';

        IF l_Ats_Id IS NULL
        THEN
            INSERT INTO At_Service (Ats_Id,
                                    Ats_At,
                                    Ats_Nst,
                                    History_Status,
                                    Ats_St,
                                    ats_ss_term)
                 VALUES (0,
                         p_At_Id,
                         p_At_Nst,
                         'A',
                         'R',
                         l_ss_term);
        ELSE
            UPDATE At_Service s
               SET s.Ats_Nst = p_At_Nst, ats_ss_term = l_ss_term
             WHERE s.Ats_Id = l_Ats_Id;
        END IF;
    END;

    PROCEDURE Save_Form_Doc (p_At_Id IN NUMBER, p_Form_Ndt IN NUMBER)
    IS
        l_Cu_Id     NUMBER;
        l_Atd_Id    NUMBER;
        l_Atd_Ndt   NUMBER;
        l_Doc_Id    NUMBER;
        l_Dh_Id     NUMBER;
    BEGIN
        BEGIN
            SELECT d.Atd_Id,
                   d.Atd_Doc,
                   d.Atd_Dh,
                   d.Atd_Ndt
              INTO l_Atd_Id,
                   l_Doc_Id,
                   l_Dh_Id,
                   l_Atd_Ndt
              FROM At_Document d
             WHERE     d.Atd_At = p_At_Id
                   AND d.History_Status = 'A'
                   AND d.Atd_Ndt IN (SELECT c.Napc_Ndt
                                       FROM Uss_Ndi.v_Ndi_At_Print_Config c
                                      WHERE c.Napc_At_Tp = 'AVOP')
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;



        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        IF NVL (l_Atd_Ndt, -1) <> NVL (p_Form_Ndt, -1)
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => l_Doc_Id,
                p_Doc_Ndt         => p_Form_Ndt,
                p_Doc_Actuality   => 'U',
                p_New_Id          => l_Doc_Id);

            Uss_Doc.Api$documents.Save_Doc_Hist (
                p_Dh_Id          => l_Dh_Id,
                p_Dh_Doc         => l_Doc_Id,
                p_Dh_Sign_Alg    => NULL,
                p_Dh_Ndt         => p_Form_Ndt,
                p_Dh_Sign_File   => NULL,
                p_Dh_Actuality   => 'U',
                p_Dh_Dt          => SYSDATE,
                p_Dh_Wu          => NULL,
                p_Dh_Src         => 'CMES',
                p_Dh_Cu          => l_Cu_Id,
                p_New_Id         => l_Dh_Id);
        END IF;

        IF l_Atd_Id IS NULL
        THEN
            INSERT INTO At_Document (Atd_Id,
                                     Atd_At,
                                     Atd_Ndt,
                                     Atd_Doc,
                                     Atd_Dh,
                                     History_Status)
                 VALUES (0,
                         p_At_Id,
                         p_Form_Ndt,
                         l_Doc_Id,
                         l_Dh_Id,
                         'A')
              RETURNING Atd_Id
                   INTO l_Atd_Id;
        ELSIF NVL (l_Atd_Ndt, -1) <> NVL (p_Form_Ndt, -1)
        THEN
            UPDATE At_Document d
               SET d.Atd_Ndt = p_Form_Ndt
             WHERE d.Atd_Id = l_Atd_Id;
        END IF;
    END;

    --=========================================================--
    --        Збереження акту ВТОРИННОЇ оцінки потреб

    --          VD    VR         VR
    --          ^     ^          ^
    --     >>   VN -> VV -> VK -> VP
    --=========================================================--
    PROCEDURE Save_Act (p_At_Id                  IN OUT NUMBER,
                        p_At_Src                 IN     VARCHAR2,
                        p_Act                    IN     CLOB,
                        p_At_Persons             IN     CLOB,
                        p_At_Sections            IN     CLOB,
                        p_At_Signers             IN     CLOB,
                        p_At_Living_Conditions   IN     CLOB,
                        p_At_Other_Spec          IN     CLOB,
                        p_At_Documents           IN     CLOB)
    IS
        l_Cu_Id                NUMBER;
        l_At_Cu                NUMBER;
        l_cnt                  NUMBER;
        l_Ndt_Id               NUMBER;
        l_At_St_Old            VARCHAR2 (10);
        l_Lock                 Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_Act                  r_Act_Avop;
        l_Persons              Api$act.t_At_Persons;
        l_Sections             Api$act.t_At_Sections;
        l_Living_Conditions    Api$act.t_At_Living_Conditions;
        l_Signers              Api$act.t_At_Signers;
        l_Other_Spec           Api$act.t_At_Other_Spec;
        l_Nst_Name             VARCHAR2 (4000);
        l_Build_Proc           VARCHAR2 (4000);
        l_Documents            Api$act.t_At_Documents;
        l_cnt_ats_all          NUMBER;
        l_cnt_ats_need         NUMBER;
        l_cnt_ats_anpoe_all    NUMBER;
        l_cnt_ats_anpoe_need   NUMBER;
        l_anpoe_id             NUMBER;
        l_is_second            NUMBER;
        l_ss_term              VARCHAR2 (10);
    BEGIN
        Write_Audit ('Save_Act');
        tools.set_nls;

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

            IF NVL (l_At_St_Old, '-') <> 'VN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування акту в поточному статусі заборонено');
            END IF;
        END IF;

        IF l_Act.At_Ap IS NOT NULL AND l_Act.At_Nst IS NOT NULL
        THEN
            l_Lock :=
                Tools.Request_Lock_With_Timeout (
                    p_Descr       =>
                        'SAVE_AT_IP_' || l_Act.At_Ap || '_' || l_Act.At_Nst,
                    p_Error_Msg   => NULL,
                    p_Timeout     => 60);
        END IF;

        SELECT MAX (t.Nst_Name)
          INTO l_Nst_Name
          FROM Act  a
               JOIN At_Service s
                   ON     a.At_Id = s.Ats_At
                      AND s.History_Status = 'A'
                      AND s.Ats_Nst = l_Act.At_Nst
               JOIN Uss_Ndi.v_Ndi_Service_Type t ON s.Ats_Nst = t.Nst_Id
         WHERE     a.At_Tp = 'AVOP'
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('VR', 'VD', 'VA')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Nst_Name IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'По цьому випадку для послуги "'
                || l_Nst_Name
                || '" вже існує акт вторинної оцінки потреб');
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Sections := Api$act.Parse_Sections (p_At_Sections);
        l_Living_Conditions :=
            Api$act.Parse_Living_Conditions (p_At_Living_Conditions);
        l_Other_Spec := Api$act.Parse_Other_Spec (p_At_Other_Spec);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);

        l_Ndt_Id :=
            NVL (
                Define_Print_Form_Ndt (p_At_Id),
                Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc, FALSE));

        IF (l_ndt_id IS NOT NULL)
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM TABLE (l_Documents) t
             WHERE     t.atd_ndt = l_ndt_id
                   AND (t.deleted IS NULL OR t.deleted = 1);

            IF (l_cnt > 1)
            THEN
                raise_application_error (
                    -20000,
                    'Документ друкованої форми задубльовано. Залиште лише один');
            END IF;
        END IF;

        SELECT COUNT (*), MAX (s.ats_ss_term)
          INTO l_is_second, l_ss_term
          FROM act t JOIN at_service s ON (s.ats_at = t.at_id)
         WHERE     t.at_tp = 'AVOP'
               AND t.at_St = 'VA'
               AND t.at_ap = l_Act.At_Ap
               AND s.history_status = 'A'
               AND s.ats_nst = l_Act.At_Nst;

        IF (l_is_second > 0 AND l_ss_term = 'O')
        THEN
            raise_application_error (
                -20000,
                'При повторному розгляді для одноразових послуг повторне створення АВОПу не потрібно!');
        END IF;

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'AVOP',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Ap               => l_Act.At_Ap,
            p_At_St               => 'VN',
            p_At_Src              => p_At_Src,
            p_At_Main_Link_Tp     => 'DECISION',
            p_At_Main_Link        => l_Act.At_Decision,
            p_At_Action_Start_Dt   =>
                NULLIF (l_Act.At_Action_Start_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Action_Stop_Dt   =>
                NULLIF (l_Act.At_Action_Stop_Dt,
                        TO_DATE ('01.01.0001', 'dd.mm.yyyy')),
            p_At_Notes            => l_Act.At_Notes,
            p_At_Live_Address     => l_Act.At_Live_Address,
            p_At_Case_Class       => l_Act.At_Case_Class,
            p_At_Conclusion_Tp    => l_Act.At_Conclusion_Tp,
            p_At_Cu               => l_Cu_Id,
            p_New_Id              => p_At_Id);

        Save_Service (p_At_Id, l_Act.At_Nst);
        --Зберігаємо документ друкованої форми
        --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
        --форми автоматично не можливо)
        --Save_Form_Doc(p_At_Id, l_Act.At_Ndt);

        -- #97410
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Other_Specs (p_At_Id         => p_At_Id,
                                  p_Other_Specs   => l_Other_Spec);
        Api$act.Save_Sections (p_At_Id           => p_At_Id,
                               p_Sections        => l_Sections,
                               p_Persons         => l_Persons,
                               p_At_Other_Spec   => l_Other_Spec);
        Api$act.Save_Living_Conditions (
            p_At_Id               => p_At_Id,
            p_Living_Conditions   => l_Living_Conditions,
            p_Cu_Id               => l_Cu_Id);
        Api$act.Save_Signers (p_At_Id     => p_At_Id,
                              p_Signers   => l_Signers,
                              p_Persons   => l_Persons);



        --#110354
        SELECT MAX (at_id)
          INTO l_anpoe_id
          FROM act anpoe
         WHERE     anpoe.at_main_link = l_Act.At_Decision
               AND anpoe.at_tp = 'ANPOE';

        --#110354
        IF l_anpoe_id IS NOT NULL
        THEN
            SELECT COUNT (1),
                   SUM (
                       CASE
                           WHEN ats.ats_nst IN (401, 403, 420) THEN 1
                           ELSE 0
                       END)
              INTO l_cnt_ats_anpoe_all, l_cnt_ats_anpoe_need
              FROM at_service ats
             WHERE ats_at = l_anpoe_id AND HISTORY_STATUS = 'A';

            IF l_cnt_ats_anpoe_all != l_cnt_ats_anpoe_need
            THEN
                SELECT COUNT (1),
                       SUM (
                           CASE
                               WHEN ats.ats_nst IN (401, 403, 420) THEN 1
                               ELSE 0
                           END)
                  INTO l_cnt_ats_all, l_cnt_ats_need
                  FROM at_service ats
                 WHERE ats_at = p_at_id AND HISTORY_STATUS = 'A';

                IF l_cnt_ats_need > 0
                THEN
                    Raise_Application_Error (
                        -20000,
                        'Так як акт ANPOE містить послуги 401, 403, 420, то їх заборонено додавати в акт AVOP');
                END IF;
            END IF;
        END IF;

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (
            p_at_id   => p_At_Id,
            p_ndt_id   =>
                COALESCE (
                    Define_Print_Form_Ndt (p_At_Id),
                    Api$act.Define_Print_Form_Ndt (
                        p_At_Id,
                        p_Raise_If_Undefined   => FALSE)));

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'VN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);

        Tools.Release_Lock (l_Lock);
    END;

    -----------------------------------------------------------
    --     ВИЗНАЧЕННЯ ТИПУ ДОКУМЕНТА ДЛЯ ДРУК. ФОРМИ АКТУ
    -----------------------------------------------------------
    FUNCTION Define_Print_Form_Ndt (p_At_Id        IN     NUMBER,
                                    p_Build_Proc      OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Ndt_Id   NUMBER;
    BEGIN
        BEGIN
            SELECT d.Atd_Ndt, c.Napc_Form_Make_Prc
              INTO l_Ndt_Id, p_Build_Proc
              FROM At_Document  d
                   JOIN Uss_Ndi.v_Ndi_At_Print_Config c
                       ON d.Atd_Ndt = c.Napc_Ndt AND c.Napc_At_Tp = 'AVOP'
             WHERE d.Atd_At = p_At_Id AND d.History_Status = 'A'
             FETCH FIRST ROW ONLY;

            IF (l_ndt_id = 804)
            THEN
                SELECT CASE
                           WHEN at_conclusion_tp = 'V1'
                           THEN
                               'Api$Act_Rpt.ACT_DOC_804_AVOP_S1'
                           ELSE
                               'Api$Act_Rpt.ACT_DOC_804_AVOP_S2'
                       END
                  INTO p_Build_Proc
                  FROM act
                 WHERE at_id = p_At_Id;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        RETURN l_Ndt_Id;
    END;

    FUNCTION Define_Print_Form_Ndt (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Build_Proc   VARCHAR2 (1000);
    BEGIN
        RETURN Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Pc,
                   a.At_Ap,
                   --Загальна інформація
                   a.At_Num,
                   --7 Номер
                   a.At_Dt,
                   --8 Дата реєстрації
                   a.At_Src,
                   --9 Джерело
                   s.Dic_Name
                       AS At_Src_Name,
                   --10 Статус
                   a.At_St,
                   St.Dic_Name
                       AS At_St_Name,
                   --25 Затверджено
                   Dt.Ndt_Id
                       AS At_Ndt,
                   Dt.Ndt_Name
                       AS At_Ndt_Name,
                   --11 Найменування форми оцінювання
                   --Ким сформовано форму оцінювання
                   --12 Найменування організації
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --14 Прізвище особи, яка сформувала --15 Ім’я особи, яка сформувала --16 По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Форма оцінювання щодо кого
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --17 Прізвище особи               --18 Ім’я особи  --19 По-батькові особи
                   --Перегляд електронних образів документів
                   --PROCEDURE Get_Form_File(p_At_Id     IN NUMBER,
                   --                        p_Atd_Dh    OUT NUMBER,
                   --                        p_File_Code OUT VARCHAR2) IS
                   --20 Перегляд доданих електронних копій документі до форми оцінювання
                   --21 Електронний документ - форми оцінювання підписаний КЕП
                   --22 Друкований образ форми оцінювання
                   --23 Форму оцінювання затверджено

                   --Відмітки про затвердження форми оцінювання керівником при погодженні та підписанні
                   a.At_Case_Class,
                   --26 Випадок класифіковано як
                   Cc.Dic_Sname
                       AS At_Case_Class_Name,
                   --Підписант (керівник) складеної форми оцінювання потреб сім’ї/особи
                   --32 Прізвище підписанта --33 Ім’я підписанта --34 По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   a.At_Action_Start_Dt,
                   a.At_Action_Stop_Dt,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   a.At_Live_Address,
                   a.At_Notes,
                   a.at_conclusion_tp,
                   c.Dic_Name
                       AS At_Conclusion_Tp_Name,
                   --Послуга
                   Sv.Ats_Nst
                       AS At_Nst,
                   t.Nst_Name
                       AS At_Nst_Name,
                   api$act.Get_Atd_Attach_Source (
                       a.at_id,
                       COALESCE (
                           Define_Print_Form_Ndt (a.at_id),
                           Api$act.Define_Print_Form_Ndt (a.at_id, l_flag)))
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Avop_St St ON a.At_St = St.Dic_Value
                   LEFT JOIN Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
                   LEFT JOIN At_Service Sv
                       ON a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON Sv.Ats_Nst = t.Nst_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type Dt
                       ON Define_Print_Form_Ndt (a.At_Id) = Dt.Ndt_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
             WHERE a.At_Id = p_At_Id;
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
                   JOIN Uss_Ndi.v_Ddn_Atop_Avop_Tp t
                       ON s.Atop_Tp = t.Dic_Value
             WHERE s.Atop_At = p_At_Id AND s.History_Status = 'A';
    END;

    PROCEDURE Get_Doc_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name, d.atd_doc AS doc_id
              FROM At_Document  d
                   JOIN At_Document_Attr a
                       ON d.Atd_Id = a.Atda_Atd AND a.History_Status = 'A'
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE     d.Atd_At = p_At_Id
                   AND d.atd_ndt = 880
                   AND d.History_Status = 'A';
    END;

    --=========================================================--
    --     Отримання даних акту ВТОРИННОЇ оцінки потреб
    --=========================================================--
    PROCEDURE Get_Act_Card (p_At_Id               IN     NUMBER,
                            p_Act_Cur                OUT SYS_REFCURSOR,
                            p_Pers_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur            OUT SYS_REFCURSOR,
                            p_Living_Conditions      OUT SYS_REFCURSOR,
                            p_Spec_Cur               OUT SYS_REFCURSOR,
                            p_Docs_Cur               OUT SYS_REFCURSOR,
                            p_Files_Cur              OUT SYS_REFCURSOR,
                            p_Attrs_Cur              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_Avop.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => 'Version 2');

        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'AVOP');


        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Living_Conditions (p_At_Id, p_Living_Conditions);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);

        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Files_Cur);
        Get_Doc_Attributes (p_At_Id, p_Attrs_Cur);
    END;

    PROCEDURE Get_Act_Card (p_At_Id               IN     NUMBER,
                            p_Act_Cur                OUT SYS_REFCURSOR,
                            p_Pers_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Cur               OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur          OUT SYS_REFCURSOR,
                            p_Signers_Cur            OUT SYS_REFCURSOR,
                            p_Living_Conditions      OUT SYS_REFCURSOR,
                            p_Spec_Cur               OUT SYS_REFCURSOR,
                            p_Docs_Cur               OUT SYS_REFCURSOR,
                            p_Files_Cur              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_Avop.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => 'Version 1');

        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'AVOP');


        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Living_Conditions (p_At_Id, p_Living_Conditions);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);

        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Files_Cur);
    END;



    PROCEDURE Get_Avop_List (p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Pc,
                   a.At_Ap,
                   --Загальна інформація
                   a.At_Num,
                   --7 Номер
                   a.At_Dt,
                   --8 Дата реєстрації
                   a.At_Src,
                   --9 Джерело
                   s.Dic_Name
                       AS At_Src_Name,
                   --10 Статус
                   a.At_St,
                   St.Dic_Name
                       AS At_St_Name,
                   --25 Затверджено
                   Dt.Ndt_Id
                       AS At_Ndt,
                   Dt.Ndt_Name
                       AS At_Ndt_Name,
                   --11 Найменування форми оцінювання
                   --Ким сформовано форму оцінювання
                   --12 Найменування організації
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --14 Прізвище особи, яка сформувала --15 Ім’я особи, яка сформувала --16 По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Форма оцінювання щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --17 Прізвище особи               --18 Ім’я особи  --19 По-батькові особи
                   --Перегляд електронних образів документів
                   --PROCEDURE Get_Form_File(p_At_Id     IN NUMBER,
                   --                        p_Atd_Dh    OUT NUMBER,
                   --                        p_File_Code OUT VARCHAR2) IS
                   --20 Перегляд доданих електронних копій документі до форми оцінювання
                   --21 Електронний документ - форми оцінювання підписаний КЕП
                   --22 Друкований образ форми оцінювання
                   --23 Форму оцінювання затверджено

                   --Відмітки про затвердження форми оцінювання керівником при погодженні та підписанні
                   a.At_Case_Class,
                   --26 Випадок класифіковано як
                   Cc.Dic_Sname
                       AS At_Case_Class_Name,
                   --Підписант (керівник) складеної форми оцінювання потреб сім’ї/особи
                   --32 Прізвище підписанта --33 Ім’я підписанта --34 По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Decision,
                   a.At_Live_Address,
                   a.At_Notes,
                   --Послуга
                   Sv.Ats_Nst
                       AS At_Nst,
                   t.Nst_Name
                       AS At_Nst_Name,
                   api$act.Get_Atd_Attach_Source (
                       a.at_id,
                       COALESCE (
                           Define_Print_Form_Ndt (a.at_id),
                           Api$act.Define_Print_Form_Ndt (a.at_id, l_flag)))
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_Ap_Src s ON a.At_Src = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_At_Avop_St St ON a.At_St = St.Dic_Value
                   LEFT JOIN Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
                   LEFT JOIN At_Service Sv
                       ON a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                       ON Sv.Ats_Nst = t.Nst_Id
                   LEFT JOIN Uss_Ndi.v_Ndi_Document_Type Dt
                       ON Define_Print_Form_Ndt (a.At_Id) = Dt.Ndt_Id;
    /*
    ndt_id = 837 «Карта визначення індивідуальних потреб особи в наданні соціальної послуги консультування»
    ndt_id = 838 «Анкета вуличного консультування»
    ndt_id = 839 «Алфавітна картка отримувача соціальної послуги»
    ndt_id = 844 «Картка визначення індивідуальних потреб особи/сім’ї в наданні соціальної послуги натуральної допомоги»
    */
    END;

    --=========================================================--
    --  API – Перегляд інформації щодо сформованих та внесених форм оцінювання потреб сім’ї/особи (вторинне оцінювання) в кабінеті НСП
    --=========================================================--
    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,   --Дата реєстрації з
                           p_At_Dt_Stop     IN     DATE,  --Дата реєстрації по
                           p_At_Num         IN     VARCHAR2,           --Номер
                           --p_At_Spec_Name IN VARCHAR2, --ПІБ кейс- менеджера, яким сформовано форму оцінювання
                           --p_At_Src    IN VARCHAR2, --Джерело
                           p_At_St          IN     VARCHAR2, --Наявність документів на підпис затвердження
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
             WHERE     a.At_Tp = 'AVOP'
                   AND a.At_Cu = l_Cu_Id
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   --shost 01.09.2023: нема ніякого сенсу для КМа фільтрувати акти по ПІБу, бо він і так бачить тільки свої акти
                   --AND Upper(Nvl(Ikis_Rbm.Tools.Getcupib(a.At_Cu), Tools.Getuserpib(a.At_Wu))) LIKE Upper(p_At_Spec_Name) || '%'
                   --Філтр по джерелу так само намає сенсу, воно завжди буде однаковим
                   --AND a.At_Src = Nvl(p_At_Src, a.At_Src)
                   --Фільтр за позначкою "Наявність документів на підпис затвердження" замінив на статус, бо він більш змістовний
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap);

        Get_Avop_List (p_Res);
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
            p_src      => 'USS_ESR.CMES$ACT_AVOP.Get_Acts_By_Ap',
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
                                       PARTITION BY a.At_Ap, s.Ats_Nst
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'VR' THEN 3
                                               WHEN 'VA' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act  a
                               JOIN At_Service s
                                   ON     a.At_Id = s.Ats_At
                                      AND s.History_Status = 'A'
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'AVOP'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               AND a.At_St NOT IN ('VD'       /*, 'VR', 'VV'*/
                                                       ))--#102247
                                                         --WHERE Rn = 1
                                                         ;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap, s.Ats_Nst
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'VR' THEN 3
                                               WHEN 'VA' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act  a
                               JOIN At_Service s
                                   ON     a.At_Id = s.Ats_At
                                      AND s.History_Status = 'A'
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'AVOP'
                               AND a.At_St NOT IN ('VD'       /*, 'VR', 'VA'*/
                                                       )
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
                                               AND l.Atl_St IN ('VV', 'VK')))--#102247
                                                                             -- WHERE Rn = 1
                                                                             ;
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_AVOP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);
        Get_Avop_List (p_Acts);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id       => p_At_Id,
            --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
            --якщо нічого не обрано визначаємо автоматично за типмо послуги
            --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
            --форми автоматично не можливо)
            p_Form_Ndt    =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
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
            --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
            --якщо нічого не обрано визначаємо автоматично за типмо послуги
            --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
            --форми автоматично не можливо)
            p_Form_Ndt               =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_Atd_Dh                 => p_Atd_Dh,
            p_File_Code              => p_File_Code,
            p_File_Signs_Code_List   => p_File_Signs_Code_List);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR)
    IS
        l_Ndt_Id       NUMBER;
        l_Build_Proc   VARCHAR2 (1000);
    BEGIN
        Write_Audit ('Get_Form_File');
        --Check_Act_Access(p_At_Id);

        --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
        --якщо нічого не обрано визначаємо автоматично за типмо послуги
        --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
        --форми автоматично не можливо)
        l_Ndt_Id :=
            COALESCE (Define_Print_Form_Ndt (p_At_Id, l_Build_Proc),
                      Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc));

        IF (l_Ndt_Id = 880)
        THEN
            Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => l_Ndt_Id,
                                  p_Doc       => p_Doc_Cur);
        /*IF (p_Doc_Cur%ROWCOUNT = 0) THEN
          raise_application_error(-20000, 'Не знайдено вкладень скану!' || SQL%ROWCOUNT );
        END IF;*/
        ELSE
            Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                                   p_At_Prj_St         => 'VN',
                                   p_Form_Ndt          => l_Ndt_Id,
                                   p_Form_Build_Proc   => l_Build_Proc,
                                   p_Doc_Cur           => p_Doc_Cur);
        END IF;
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ІДЕНТИФІКАТОРІВ ДОКУМЕНТУ ДРУКОВАНОЇ ФОРМИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Form_Doc');
        Api$act.Get_Form_Doc (
            p_At_Id     => p_At_Id,
            p_Atd_Ndt   =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
    BEGIN
        Api$act.Get_Form_Doc_Src (
            p_At_Id     => p_At_Id,
            p_Atd_Ndt   =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_Doc_Src   => p_Doc_Src);
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
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМа
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        --l_doc_Attach_Src VARCHAR2(10);
        l_st   VARCHAR2 (10) := 'VV';
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (
            p_At_Id       => p_At_Id,
            --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
            --якщо нічого не обрано визначаємо автоматично за типмо послуги
            --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
            --форми автоматично не можливо)
            p_Ndt_Id      =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            /*Get_Form_Doc_Src(p_at_id, l_doc_Attach_Src);
            IF (l_doc_Attach_Src = 'HAND' AND l_is_used = 'T') THEN
              l_st := 'VK';
              Cmes$act.Set_All_Signed_Rc(p_At_Id => p_At_Id,
                p_Ndt_Id => Coalesce(Define_Print_Form_Ndt(p_At_Id), Api$act.Define_Print_Form_Ndt(p_At_Id)));
            ELSIF (l_doc_Attach_Src = 'TABLET' AND l_is_used = 'T' AND Api$act.Is_All_Signed(p_At_Id => p_At_Id, p_Ati_Tp => 'RC')) THEN
              l_st := 'VK';
            END IF;*/

            api$act.Handle_Cm_Sign (
                p_at_id,
                l_st,
                'VK',
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
                l_st);

            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'VN',
                p_At_St_New   => l_st,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Rc');
        Cmes$act.Set_Signed_Rc (
            p_At_Id       => p_At_Id,
            --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
            --якщо нічого не обрано визначаємо автоматично за типмо послуги
            --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
            --форми автоматично не можливо)
            p_Ndt_Id      =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'VV',
                p_At_St_New   => 'VK',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Cmes$act.Set_Signed_Pr (
            p_At_Id       => p_At_Id,
            --Спочатку намагаємось визначити тип документа для друк. форми який вибрали явно(вручну)
            --якщо нічого не обрано визначаємо автоматично за типмо послуги
            --(для деяких послуг може буди декілька варіантів форм, в такому випадку визначити тип
            --форми автоматично не можливо)
            p_Ndt_Id      =>
                COALESCE (Define_Print_Form_Ndt (p_At_Id),
                          Api$act.Define_Print_Form_Ndt (p_At_Id)),
            p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'VK',
            p_At_St_New   => 'VP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        --Для всіх рішень по зверненню до якого привязаний акт з таким самим НСП
        FOR Rec IN (SELECT d.At_Id AS Decision_Id, d.*
                      FROM Act  a
                           JOIN Act d
                               ON     a.At_Ap = d.At_Ap
                                  AND a.At_Rnspm = d.At_Rnspm
                                  AND d.At_Tp = 'PDSP'
                                  AND d.At_St IN ('SGO',
                                                  'SGM',
                                                  'SA',
                                                  'O.SA',
                                                  'SNR')
                     WHERE a.At_Id = p_At_Id)
        LOOP
            IF (    rec.at_st = 'SA'
                AND api$act.Check_PDST_ST_SA (Rec.Decision_Id) = '__')
            THEN
                CONTINUE;
            END IF;

            IF (    rec.at_st = 'SNR'
                AND api$act.Check_PDST_ST_SNR (Rec.Decision_Id) = '__')
            THEN
                CONTINUE;
            END IF;

            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);
        END LOOP;
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "СКАСОВАНО"
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
            p_At_St_Old      => 'VN',
            p_At_St_New      => 'VD',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
    END;

    -----------------------------------------------------------
    -- ПЕРЕВОД АКТУ В СТАН "ВІДХИЛЕНО"
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
              (    l_At_St = 'VV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'VK'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'VR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'VR',
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;
END Cmes$act_Avop;
/