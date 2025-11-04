/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_IP
IS
    -- Author  : SHOSTAK
    -- Created : 25.08.2023 12:10:38 PM
    -- Purpose : Робота з індивідуальними планами #91152

    Pkg   VARCHAR2 (50) := 'CMES$ACT_IP';

    TYPE r_Act IS RECORD
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
        At_Avop               NUMBER,
        At_Decision           NUMBER,
        At_Case_Class         Act.At_Case_Class%TYPE,
        At_Nst                NUMBER
    );

    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Sections          IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Other_Spec        IN     CLOB,
                        p_At_Signers           IN     CLOB,
                        p_At_Documents         IN     CLOB,
                        p_At_Results           IN     CLOB);

    FUNCTION Get_At_Ip_Name (p_At_Id      IN NUMBER,
                             p_Is_Error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2;

    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Docs_Cur           OUT SYS_REFCURSOR,
                            p_Files_Cur          OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR,
                            p_Attrs_Cur          OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Docs_Cur           OUT SYS_REFCURSOR,
                            p_Files_Cur          OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_Cm (p_At_Dt_Start    IN     DATE,
                           p_At_Dt_Stop     IN     DATE,
                           p_At_Num         IN     VARCHAR2,
                           p_At_St          IN     VARCHAR2,
                           p_At_Main_Link   IN     NUMBER,
                           p_At_Pc          IN     NUMBER,
                           p_At_Ap          IN     NUMBER,
                           p_Res               OUT SYS_REFCURSOR);

    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              p_At_Dt_Start     IN     DATE,
                              p_At_Dt_Stop      IN     DATE,
                              p_At_Num          IN     VARCHAR2,
                              p_At_Src          IN     VARCHAR2,
                              p_At_Spec_Name    IN     VARCHAR2,
                              p_Need_Sign       IN     VARCHAR2,
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

    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;

    PROCEDURE Set_Archive_Cm (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE get_united_form_file (p_at_id       IN     NUMBER,
                                    p_doc_cur        OUT SYS_REFCURSOR,
                                    p_files_cur      OUT SYS_REFCURSOR);

    PROCEDURE Create_Main_Ip (p_at_id IN NUMBER, p_new_id OUT NUMBER);


    FUNCTION get_ss_cnt (p_At_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION check_main_ip (p_At_Id IN NUMBER)
        RETURN NUMBER;
END Cmes$act_Ip;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_IP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_IP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_IP TO II01RC_USS_ESR_WEB
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_IP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_IP
IS
    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    FUNCTION Parse_Act (p_Xml IN CLOB)
        RETURN r_Act
    IS
        l_Result   r_Act;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN l_Result;
        END IF;

        EXECUTE IMMEDIATE Type2xmltable (Pkg, 'r_Act', TRUE)
            INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу інд. плану: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    PROCEDURE logS (p_src VARCHAR2, p_regular_params VARCHAR2)
    IS
        l_Cu_Id   NUMBER;
        l_Sc_Id   NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        BEGIN
            l_Sc_Id := Ikis_Rbm.Tools.GetCuSc (l_Cu_Id);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        tools.logSes (
            Pkg || '.' || UPPER (p_src),
               'cu_Id='
            || l_Cu_Id
            || CHR (13)
            || CHR (10)
            || 'sc_Id='
            || l_Sc_Id
            || CHR (13)
            || CHR (10)
            || p_regular_params);
    END;

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

    -----------------------------------------------------------
    --     ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id                IN OUT NUMBER,
                        p_At_Src               IN     VARCHAR2,
                        p_Act                  IN     CLOB,
                        p_At_Persons           IN     CLOB,
                        p_At_Sections          IN     CLOB,
                        p_At_Individual_Plan   IN     CLOB,
                        p_At_Other_Spec        IN     CLOB,
                        p_At_Signers           IN     CLOB,
                        p_At_Documents         IN     CLOB,
                        p_At_Results           IN     CLOB)
    IS
        l_Cu_Id             NUMBER;
        l_Act               r_Act;
        l_Lock              Ikis_Sys.Ikis_Lock.t_Lockhandler;
        l_At_Cu             NUMBER;
        l_cnt               NUMBER;
        l_pdsp_id           NUMBER;
        l_ndt_id            NUMBER;
        l_At_St_Old         VARCHAR2 (10);
        l_Persons           Api$act.t_At_Persons;
        l_Sections          Api$act.t_At_Sections;
        l_Signers           Api$act.t_At_Signers;
        l_Individual_Plan   Api$act.t_At_Individual_Plan;
        l_Other_Spec        Api$act.t_At_Other_Spec;
        l_Nst_Name          VARCHAR2 (4000);
        l_Build_Proc        VARCHAR2 (4000);
        l_Documents         Api$act.t_At_Documents;
        l_Results           Api$act.t_At_Results;
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

        IF     l_Act.At_Avop IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Avop)
        THEN
            Raise_Application_Error (
                -20000,
                'Вказано акт вторинної оцінки по іншому надавачу');
        END IF;

        IF     l_Act.At_Decision IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Decision)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано рішення по іншому надавачу');
        END IF;

        SELECT MAX (t.at_main_link)
          INTO l_pdsp_id
          FROM act t
         WHERE t.at_id = p_At_Id AND t.at_main_link_tp = 'DECISION';

        /*
        if (l_cnt > 0) then
          raise_application_error(-20000, 'Редагування об`єднаного ІП неможливе!');
        end if;
        */
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

            IF NVL (l_At_St_Old, '-') <> 'IN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування індивідуального плану в поточному статусі заборонено');
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
         WHERE     a.At_Tp = 'IP'
               AND (   l_cnt > 0 AND a.at_main_link_tp = 'DECISION'
                    OR l_cnt = 0 AND a.at_main_link_tp != 'DECISION')
               AND a.At_Ap = l_Act.At_Ap
               AND a.At_St NOT IN ('IR', 'ID', 'IA')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_Nst_Name IS NOT NULL
        THEN
            Raise_Application_Error (
                -20000,
                   'По цьому випадку для послуги "'
                || l_Nst_Name
                || '" вже існує індивідуальний план');
        END IF;

        IF (l_Act.At_Nst IN (401, 403, 420))
        THEN
            raise_application_error (
                -20000,
                'Для цієї послуги створення ІП непотрібне');
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Sections := Api$act.Parse_Sections (p_At_Sections);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Results := Api$act.Parse_At_Results (p_At_Results);

        l_Individual_Plan :=
            Api$act.Parse_Individual_Plan (p_At_Individual_Plan);
        l_Other_Spec := Api$act.Parse_Other_Spec (p_At_Other_Spec);


        l_Ndt_Id :=
            Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc, FALSE);

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

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        IF (l_pdsp_id IS NULL)
        THEN
            Api$act.Save_Act (
                p_At_Id                => p_At_Id,
                p_At_Tp                => 'IP',
                p_At_Pc                => l_Act.At_Pc,
                p_At_Num               => NULL,
                p_At_Dt                => l_Act.At_Dt,
                p_At_Org               => l_Act.At_Org,
                p_At_Sc                => l_Act.At_Sc,
                p_At_Rnspm             => l_Act.At_Rnspm,
                p_At_Rnp               => NULL,
                p_At_Ap                => l_Act.At_Ap,
                p_At_St                => 'IN',
                p_At_Src               => p_At_Src,
                p_At_Main_Link_Tp      => 'AVOP',
                p_At_Main_Link         => l_Act.At_Avop,
                p_At_Action_Start_Dt   => l_Act.At_Action_Start_Dt,
                p_At_Action_Stop_Dt    => l_Act.At_Action_Stop_Dt,
                p_At_Notes             => l_Act.At_Notes,
                p_At_Live_Address      => l_Act.At_Live_Address,
                p_At_Cu                => l_Cu_Id,
                p_At_Case_Class        => l_Act.At_Case_class,
                p_New_Id               => p_At_Id);

            Save_Service (p_At_Id, l_Act.At_Nst);
        ELSE
            -- редагування об'єднаного ІП
            Api$act.Save_Act (
                p_At_Id                => p_At_Id,
                p_At_Tp                => 'IP',
                p_At_Pc                => l_Act.At_Pc,
                p_At_Dt                => l_Act.At_Dt,
                p_At_Org               => l_Act.At_Org,
                p_At_Sc                => l_Act.At_Sc,
                p_At_Rnspm             => l_Act.At_Rnspm,
                p_At_Rnp               => NULL,
                p_At_Ap                => l_Act.At_Ap,
                p_At_St                => 'IN',
                p_At_Src               => p_At_Src,
                p_At_Main_Link_Tp      => 'DECISION',
                p_At_Main_Link         => l_pdsp_id,
                p_At_Action_Start_Dt   => l_Act.At_Action_Start_Dt,
                p_At_Action_Stop_Dt    => l_Act.At_Action_Stop_Dt,
                p_At_Notes             => l_Act.At_Notes,
                p_At_Live_Address      => l_Act.At_Live_Address,
                p_At_Cu                => l_Cu_Id,
                p_At_Case_Class        => l_Act.At_Case_class,
                p_New_Id               => p_At_Id);
        END IF;

        Api$act.Save_Persons (p_At_Id     => p_At_Id,
                              p_Persons   => l_Persons,
                              p_Cu_Id     => l_Cu_Id);
        Api$act.Save_Sections (p_At_Id      => p_At_Id,
                               p_Sections   => l_Sections,
                               p_Persons    => l_Persons);
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
        Api$act.Save_At_Results (p_At_Id => p_At_Id, p_Results => l_Results);

        -- #97410
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);

        IF l_Act.At_Decision IS NOT NULL
        THEN
            Api$act.Save_Link (p_Atk_At        => p_At_Id,
                               p_Atk_Link_At   => l_Act.At_Decision,
                               p_Atk_Tp        => 'DECISION');
        END IF;

        -- обнулення типу вкладення і підписів
        api$act.Handle_Form_Save (
            p_at_id   => p_At_Id,
            p_ndt_id   =>
                Api$act.Define_Print_Form_Ndt (
                    p_At_Id,
                    p_Raise_If_Undefined   => FALSE));

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'IN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);

        Tools.Release_Lock (l_Lock);
    END;

    FUNCTION Get_At_Ip_Name (p_At_Id      IN NUMBER,
                             p_Is_Error      VARCHAR2 DEFAULT 'T')
        RETURN VARCHAR2
    IS
        l_Ndt_Id     NUMBER;
        l_Ndt_Name   Uss_Ndi.v_Ndi_Document_Type.Ndt_Name%TYPE;
    BEGIN
        -- RETURN NULL;
        l_Ndt_Id :=
            Api$act.Define_Print_Form_Ndt (
                p_At_Id   => p_At_Id,
                p_Raise_If_Undefined   =>
                    CASE WHEN p_Is_Error = 'T' THEN TRUE ELSE FALSE END);

        IF l_Ndt_Id IS NOT NULL
        THEN
            SELECT t.Ndt_Name
              INTO l_Ndt_Name
              FROM Uss_Ndi.v_Ndi_Document_Type t
             WHERE t.Ndt_Id = l_Ndt_Id;
        END IF;

        RETURN l_Ndt_Name;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ОСНОВНИХ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   Src.Dic_Name
                       AS At_Src_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Avop,
                   --Ким сформовано індивідуальний план
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Найменування організації
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Індивідуальний план надання соціальної послуги щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Найменування індивідуального плану
                   Get_At_Ip_Name (a.At_Id, 'F')
                       AS At_Ndt_Name,
                   --Послуга
                   --Sv.Ats_Nst AS At_Nst, t.Nst_Name AS At_Nst_Name,
                   CASE
                       WHEN     get_ss_cnt (a.at_id) > 1
                            AND cmes$act_ip.check_main_ip (a.at_id) = 1
                       THEN
                           NULL
                       ELSE
                           (SELECT MAX (sv.ats_nst)
                              FROM At_Service Sv
                             WHERE     a.At_Id = Sv.Ats_At
                                   AND Sv.History_Status = 'A')
                   END
                       AS At_Nst,
                   (SELECT LISTAGG (t.nst_name, ', ')
                               WITHIN GROUP (ORDER BY 1)
                      FROM At_Service  Sv
                           LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                               ON Sv.Ats_Nst = t.Nst_Id
                     WHERE a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A')
                       AS At_Nst_Name,
                   --Рішення
                   CASE
                       WHEN a.at_main_link_tp = 'DECISION'
                       THEN
                           a.at_main_link
                       ELSE
                           l.Atk_Link_At
                   END
                       AS At_Decision,
                   cc.DIC_NAME
                       AS At_Case_Class_Name,
                   CASE
                       WHEN     get_ss_cnt (a.at_id) > 1
                            AND cmes$act_ip.check_main_ip (a.at_id) = 1
                       THEN
                           api$act.Get_Atd_Attach_Source (a.at_id, 1022)
                       ELSE
                           api$act.Get_Atd_Attach_Source (
                               a.at_id,
                               Api$act.Define_Print_Form_Ndt (a.at_id,
                                                              l_flag))
                   END
                       AS Atd_Attach_Source,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   CASE
                       WHEN     get_ss_cnt (a.at_id) > 1
                            AND check_main_ip (a.at_id) = 1
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS is_united
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Ip_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.At_Src = Src.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   /*LEFT JOIN At_Service Sv
                     ON a.At_Id = Sv.Ats_At
                    AND Sv.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                     ON Sv.Ats_Nst = t.Nst_Id*/
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'DECISION'
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
             WHERE a.At_Id = p_At_Id;
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
    --     ОТРИМАННЯ КІЛЬКОСТІ ПОСЛУГ ЯКІ НАДАЮТЬСЯ
    -----------------------------------------------------------
    FUNCTION get_ss_cnt (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt       NUMBER;
        l_pdsp_id   NUMBER;
    BEGIN
        SELECT MAX (pdsp.at_id)
          INTO l_pdsp_id
          FROM act  ip
               JOIN act avop ON (avop.at_id = ip.at_main_link)
               JOIN act pdsp ON (pdsp.at_id = avop.at_main_link)
         WHERE ip.at_id = p_at_id;

        IF (l_pdsp_id IS NULL)
        THEN
            SELECT MAX (pdsp.at_id)
              INTO l_pdsp_id
              FROM act ip JOIN act pdsp ON (pdsp.at_id = ip.at_main_link)
             WHERE ip.at_id = p_at_id AND pdsp.at_tp = 'PDSP';
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM act pdsp JOIN at_service s ON (s.ats_at = pdsp.at_id)
         WHERE     pdsp.at_id = l_pdsp_id
               AND s.history_status = 'A'
               AND s.ats_st IN ('P', 'SG', 'ST')
               AND s.ats_ss_term = 'P'
               AND s.ats_nst NOT IN (401, 403, 420); -- Для них не потрібно ІП

        RETURN l_cnt;
    END;


    -----------------------------------------------------------
    --     ЧИ АКТ ОСНОВНИЙ
    -----------------------------------------------------------
    FUNCTION check_main_ip (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_ss_cnt   NUMBER := get_ss_cnt (p_at_id);
        l_cnt      NUMBER;
    BEGIN
        SELECT CASE
                   WHEN ip.at_main_link_tp = 'DECISION' OR l_ss_cnt = 1
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_cnt
          FROM act ip
         WHERE ip.at_id = p_at_id;

        RETURN l_cnt;
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
             WHERE t.Atr_At = p_At_Id;
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
                   AND d.atd_ndt = 890
                   AND d.History_Status = 'A';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ КАРТКИ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Docs_Cur           OUT SYS_REFCURSOR,
                            p_Files_Cur          OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR,
                            p_Attrs_Cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_IP.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => 'Version 2');


        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'IP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Indivilual_Plan (p_At_Id, p_Ip_Cur);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);

        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Files_Cur);
        Get_Results (p_At_Id, p_Results_Cur);
        Get_Doc_Attributes (p_At_Id, p_Attrs_Cur);
    END;

    PROCEDURE Get_Act_Card (p_At_Id           IN     NUMBER,
                            p_Act_Cur            OUT SYS_REFCURSOR,
                            p_Pers_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Cur           OUT SYS_REFCURSOR,
                            p_Sect_Feat_Cur      OUT SYS_REFCURSOR,
                            p_Ip_Cur             OUT SYS_REFCURSOR,
                            p_Spec_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur        OUT SYS_REFCURSOR,
                            p_Docs_Cur           OUT SYS_REFCURSOR,
                            p_Files_Cur          OUT SYS_REFCURSOR,
                            p_Results_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Tools.LOG (p_src              => 'USS_ESR.Cmes$act_IP.Get_Act_Card',
                   p_obj_tp           => 'ACT',
                   p_obj_id           => p_At_Id,
                   p_regular_params   => 'Version 1');
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);
        Api$Act.Check_At_Tp (p_At_Id, 'IP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Sections (p_At_Id, p_Sect_Cur);
        Api$act.Get_Section_Features (p_At_Id, p_Sect_Feat_Cur);
        Api$act.Get_Indivilual_Plan (p_At_Id, p_Ip_Cur);
        Get_Other_Spec (p_At_Id, p_Spec_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);

        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Files_Cur);
        Get_Results (p_At_Id, p_Results_Cur);
    END;

    -----------------------------------------------------------
    --  ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
        l_flag   BOOLEAN := FALSE;
    BEGIN
        OPEN p_Res FOR
            SELECT a.*,
                   s.Dic_Name
                       AS At_St_Name,
                   Src.Dic_Name
                       AS At_Src_Name,
                   o.Org_Name
                       AS At_Org_Name,
                   a.At_Main_Link
                       AS At_Avop,
                   --Ким сформовано індивідуальний план
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --Найменування організації
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Індивідуальний план надання соціальної послуги щодо кого
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Найменування індивідуального плану
                   Get_At_Ip_Name (a.At_Id, 'F')
                       AS At_Ndt_Name,
                   --Послуга
                   --Sv.Ats_Nst AS At_Nst, t.Nst_Name AS At_Nst_Name,
                    (SELECT MAX (sv.ats_nst)
                       FROM At_Service Sv
                      WHERE a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A')
                       AS At_Nst,
                   (SELECT LISTAGG (t.nst_name, ', ')
                               WITHIN GROUP (ORDER BY 1)
                      FROM At_Service  Sv
                           LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                               ON Sv.Ats_Nst = t.Nst_Id
                     WHERE a.At_Id = Sv.Ats_At AND Sv.History_Status = 'A')
                       AS At_Nst_Name,
                   --Рішення
                   CASE
                       WHEN a.at_main_link_tp = 'DECISION'
                       THEN
                           a.at_main_link
                       ELSE
                           l.Atk_Link_At
                   END
                       AS At_Decision,
                   CASE
                       WHEN     get_ss_cnt (a.at_id) > 1
                            AND cmes$act_ip.check_main_ip (a.at_id) = 1
                       THEN
                           api$act.Get_Atd_Attach_Source (a.at_id, 1022)
                       ELSE
                           api$act.Get_Atd_Attach_Source (
                               a.at_id,
                               Api$act.Define_Print_Form_Ndt (a.at_id,
                                                              l_flag))
                   END
                       AS Atd_Attach_Source,
                   CASE
                       WHEN     get_ss_cnt (a.at_id) > 1
                            AND check_main_ip (a.at_id) = 1
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS is_united
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Ip_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Src ON a.At_Src = Src.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   /*LEFT JOIN At_Service Sv
                     ON a.At_Id = Sv.Ats_At
                    AND Sv.History_Status = 'A'
                   LEFT JOIN Uss_Ndi.v_Ndi_Service_Type t
                     ON Sv.Ats_Nst = t.Nst_Id*/
                   LEFT JOIN At_Links l
                       ON a.At_Id = l.Atk_At AND l.Atk_Tp = 'DECISION';
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ДЛЯ КЕЙС-МЕНЕДЖЕРА
    -----------------------------------------------------------
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

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_IP.Get_Acts_Cm',
            p_obj_tp   => 'CMES_CU_ID',
            p_obj_id   => l_Cu_Id,
            p_regular_params   =>
                   'p_At_Dt_Start='
                || p_At_Dt_Start
                || ', p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ', p_At_Num='
                || p_At_Num
                || ', p_At_St='
                || p_At_St
                || ', p_At_Main_Link='
                || p_At_Main_Link
                || ', p_At_Pc='
                || p_At_Pc
                || ', p_At_Ap='
                || p_At_Ap);

        DELETE FROM Tmp_Work_Ids;

        --Вибираємо всі акти, які закріплені за поточним користувачем
        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'IP'
                   AND (a.At_Cu = l_Cu_Id)
                   --Додаткові фільтри
                   AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                   AND NVL (p_At_Dt_Stop, a.At_Dt)
                   AND (p_At_St IS NULL OR a.At_St = p_At_St)
                   AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                   AND (   p_At_Main_Link IS NULL
                        OR a.At_Main_Link = p_At_Main_Link)
                   AND (p_At_Pc IS NULL OR a.At_Pc = p_At_Pc)
                   AND (p_At_Ap IS NULL OR a.At_Ap = p_At_Ap);

        Get_Act_List (p_Res);
    END;

    -----------------------------------------------------------
    --    ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ПО ЗВЕРНЕННЮ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Ap (p_Ap_Id           IN     NUMBER,
                              p_Cmes_Owner_Id   IN     NUMBER,
                              --Не знаю навіщо, але за постановкою ЖХ потрібні фільтри
                              p_At_Dt_Start     IN     DATE,
                              p_At_Dt_Stop      IN     DATE,
                              p_At_Num          IN     VARCHAR2,
                              p_At_Src          IN     VARCHAR2,
                              p_At_Spec_Name    IN     VARCHAR2,
                              p_Need_Sign       IN     VARCHAR2,
                              p_Acts               OUT SYS_REFCURSOR)
    IS
        l_Sc_Id   NUMBER;
        l_cnt     NUMBER;
    BEGIN
        Write_Audit ('Get_Acts_By_Ap');

        --Запит від ОСП
        l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_IP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', p_At_Dt_Start='
                || p_At_Dt_Start
                || ', p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ', p_At_Num='
                || p_At_Num
                || ', p_At_Src='
                || p_At_Src
                || ', p_At_Spec_Name='
                || p_At_Spec_Name
                || ', p_Need_Sign='
                || p_Need_Sign
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        DELETE FROM Tmp_Work_Ids;

        SELECT COUNT (*)
          INTO l_cnt
          FROM act t
         WHERE     t.at_ap = p_Ap_Id
               AND t.at_tp = 'IP'
               AND t.at_main_link_tp = 'DECISION'
               AND t.At_St NOT IN ('ID');

        --Запит від НСП
        IF     p_Cmes_Owner_Id IS NOT NULL
           AND Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                   p_Cmes_Id         => Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                   p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                   p_Cr_Code         => 'NSP_SPEC')
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT DISTINCT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap, s.Ats_Nst
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE
                                               WHEN     a.at_main_link_tp =
                                                        'DECISION'
                                                    AND a.At_St NOT IN ('IR')
                                               THEN
                                                   0
                                               WHEN     a.at_main_link_tp =
                                                        'DECISION'
                                                    AND a.At_St IN ('IA')
                                               THEN
                                                   2
                                               WHEN a.At_St = 'IA'
                                               THEN
                                                   2
                                               WHEN a.At_St = 'IR'
                                               THEN
                                                   3
                                               ELSE
                                                   1
                                           END,
                                           a.at_id DESC)    AS Rn
                          FROM Act  a
                               JOIN At_Service s
                                   ON     a.At_Id = s.Ats_At
                                      AND s.History_Status = 'A'
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'IP'
                               AND (       l_cnt > 0
                                       AND a.at_main_link_tp = 'DECISION'
                                    OR l_cnt = 0)
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               AND a.At_St NOT IN ('ID')
                               AND a.At_Dt BETWEEN NVL (p_At_Dt_Start,
                                                        a.At_Dt)
                                               AND NVL (p_At_Dt_Stop,
                                                        a.At_Dt)
                               AND (   p_At_Num IS NULL
                                    OR a.At_Num LIKE p_At_Num || '%')
                               AND (p_At_Src IS NULL OR a.At_Src = p_At_Src)
                               AND (   NVL (p_Need_Sign, 'F') = 'F'
                                    OR a.At_St = 'IK')
                               AND (   p_At_Spec_Name IS NULL
                                    OR EXISTS
                                           (SELECT 1
                                              FROM Ikis_Rbm.v_Cmes_Users u
                                             WHERE     u.Cu_Id = a.At_Cu
                                                   AND UPPER (u.Cu_Pib) LIKE
                                                              UPPER (
                                                                  p_At_Spec_Name)
                                                           || '%')))--WHERE Rn = 1
                                                                    ;
        ELSE
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT DISTINCT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       PARTITION BY a.At_Ap, s.Ats_Nst
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE
                                               WHEN     a.at_main_link_tp =
                                                        'DECISION'
                                                    AND a.At_St NOT IN ('IR')
                                               THEN
                                                   0
                                               WHEN     a.at_main_link_tp =
                                                        'DECISION'
                                                    AND a.At_St IN ('IA')
                                               THEN
                                                   2
                                               WHEN a.At_St = 'IA'
                                               THEN
                                                   2
                                               WHEN a.At_St = 'IR'
                                               THEN
                                                   3
                                               ELSE
                                                   1
                                           END,
                                           a.at_id DESC)    AS Rn
                          FROM Act  a
                               JOIN At_Service s
                                   ON     a.At_Id = s.Ats_At
                                      AND s.History_Status = 'A'
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'IP'
                               AND a.At_St NOT IN ('ID')
                               AND (       l_cnt > 0
                                       AND a.at_main_link_tp = 'DECISION'
                                    OR l_cnt = 0)
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
                                               AND l.Atl_St IN ('IV', 'IK'))
                               AND a.At_Dt BETWEEN NVL (p_At_Dt_Start,
                                                        a.At_Dt)
                                               AND NVL (p_At_Dt_Stop,
                                                        a.At_Dt)
                               AND (   p_At_Num IS NULL
                                    OR a.At_Num LIKE p_At_Num || '%')
                               AND a.At_Src = NVL (p_At_Src, a.At_Src)
                               AND (   NVL (p_Need_Sign, 'F') = 'F'
                                    OR a.At_St = 'IV')
                               AND (   p_At_Spec_Name IS NULL
                                    OR EXISTS
                                           (SELECT 1
                                              FROM Ikis_Rbm.v_Cmes_Users u
                                             WHERE     u.Cu_Id = a.At_Cu
                                                   AND UPPER (u.Cu_Pib) LIKE
                                                              UPPER (
                                                                  p_At_Spec_Name)
                                                           || '%')))--WHERE Rn = 1
                                                                    ;
        END IF;

        CMES$ACT.Log_Tmp_work_Ids_Amnt (
            p_src      => 'USS_ESR.CMES$ACT_IP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
                || ', p_At_Dt_Start='
                || p_At_Dt_Start
                || ', p_At_Dt_Stop='
                || p_At_Dt_Stop
                || ', p_At_Num='
                || p_At_Num
                || ', p_At_Src='
                || p_At_Src
                || ', p_At_Spec_Name='
                || p_At_Spec_Name
                || ', p_Need_Sign='
                || p_Need_Sign
                || ', l_Sc_Id='
                || l_Sc_Id
                || ', p_Cmes_Id='
                || Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider);

        Get_Act_List (p_Acts);
    END;

    -----------------------------------------------------------
    --            ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --               (вже побудованої)
    -----------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2)
    IS
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSE
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        END IF;

        Api$act.Get_Form_File (p_At_Id       => p_At_Id,
                               p_Form_Ndt    => l_ndt_id,
                               p_Atd_Dh      => p_Atd_Dh,
                               p_File_Code   => p_File_Code);
    END;

    ---------------------------------------------------------------
    --              ОТРИМАННЯ ДРУКОВАНОЇ ФОРМИ АКТУ
    --        (вже побудованої, з кодами підписів через кому)
    ---------------------------------------------------------------
    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2)
    IS
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSE
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        END IF;

        Api$act.Get_Form_File (
            p_At_Id                  => p_At_Id,
            p_Form_Ndt               => l_ndt_Id,
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
        l_is_main      NUMBER := check_main_ip (p_at_id);
        l_ss_cnt       NUMBER := get_ss_cnt (p_at_id);
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        --raise_application_error(-20000, 'l_is_main='||l_is_main||';l_ss_cnt='||l_ss_cnt);
        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => 1022,
                                  p_Doc       => p_Doc_Cur);
            RETURN;
        END IF;

        l_Ndt_Id := Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);

        IF (l_Ndt_Id = 890)
        THEN
            Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => l_Ndt_Id,
                                  p_Doc       => p_Doc_Cur);
        ELSE
            Api$act.Get_Form_File (p_At_Id             => p_At_Id,
                                   p_At_Prj_St         => 'IN',
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
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    BEGIN
        Write_Audit ('Get_Form_Doc');

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSE
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        END IF;

        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => l_ndt_id,
                              p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- ОТРИМАННЯ ТИПУ ВКЛАДЕННЯ ДОКУМЕНТА (Ручне чи автоматичне)
    -----------------------------------------------------------
    PROCEDURE Get_Form_Doc_Src (p_At_Id IN NUMBER, p_Doc_Src OUT VARCHAR2)
    IS
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    BEGIN
        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSE
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        END IF;

        Api$act.Get_Form_Doc_Src (p_At_Id     => p_At_Id,
                                  p_Atd_Ndt   => l_ndt_id,
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
        l_st        VARCHAR2 (10) := 'IV';
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    --l_is_used VARCHAR2(10) := tools.ggp('HAND_SIGN_OSP');
    BEGIN
        Write_Audit ('Set_Signed_Cm');

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSE
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        END IF;

        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_ndt_id      => l_ndt_id,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            -- якщо у нас надається більше 1 послуги то це дочірні ІПи і треба їх буде об'єднати в один
            IF (l_is_main = 0)
            THEN
                raise_application_error (
                    -20000,
                    'Підпис доступний лише по об`єднаному ІП!');
            ELSE
                api$act.Handle_Cm_Sign (p_at_id,
                                        l_st,
                                        'IK',
                                        l_ndt_id,
                                        l_st);
            END IF;

            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'IN',
                p_At_St_New   => l_st,
                --p_At_Action_Stop_Dt => SYSDATE,
                p_Log_Msg     => CHR (38) || '251',
                p_Wrong_St_Msg   =>
                    'Відправка на підпис отримувачу можлива лише в стані проекту');

            -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
            FOR xx IN (SELECT t.atk_at     AS at_id
                         FROM at_links t
                        WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
            LOOP
                Api$act.Set_At_St (
                    p_At_Id       => xx.at_id,
                    p_At_St_Old   => 'IN',
                    p_At_St_New   => l_st,
                    --p_At_Action_Stop_Dt => SYSDATE,
                    p_Log_Msg     => CHR (38) || '315',
                    p_Wrong_St_Msg   =>
                        'Відправка на підпис отримувачу можлива лише в стані проекту');
            END LOOP;
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ ОСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Rc (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Rc');

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSIF (l_is_main = 1)
        THEN
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        ELSE
            raise_application_error (
                -20000,
                'Підпис доступний лише по об`єднаному ІП!');
        END IF;

        Cmes$act.Set_Signed_Rc (p_At_Id       => p_At_Id,
                                p_ndt_Id      => l_ndt_id,
                                p_file_code   => p_file_code);

        IF Api$act.Is_All_Signed (p_At_Id => p_At_Id, p_Ati_Tp => 'RC')
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'IV',
                p_At_St_New   => 'IK',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Підписання отримувачем можливо лише в стані "Очікує підписання"');

            -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
            FOR xx IN (SELECT t.atk_at     AS at_id
                         FROM at_links t
                        WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
            LOOP
                Api$act.Set_At_St (
                    p_At_Id       => xx.at_id,
                    p_At_St_Old   => 'IV',
                    p_At_St_New   => 'IK',
                    --p_At_Action_Stop_Dt => SYSDATE,
                    p_Log_Msg     => CHR (38) || '316',
                    p_Wrong_St_Msg   =>
                        'Підписання отримувачем можливо лише в стані "Очікує підписання"');
            END LOOP;
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_At_Id       IN NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_is_main   NUMBER := check_main_ip (p_at_id);
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_ndt_id    NUMBER;
        l_at        act%ROWTYPE;
        l_qty       NUMBER;
        l_cnt       NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        Tools.Start_Log_Ses_Id ('IP', p_At_Id);
        logS ('Set_Signed_Pr', 'p_At_Id = ' || p_At_Id);

        IF (l_is_main = 1 AND l_ss_cnt > 1)
        THEN
            l_ndt_id := 1022;
        ELSIF (l_is_main = 1)
        THEN
            l_ndt_id := Api$act.Define_Print_Form_Ndt (p_At_Id);
        ELSE
            raise_application_error (
                -20000,
                'Підпис доступний лише по об`єднаному ІП!');
        END IF;

        Cmes$act.Set_Signed_Pr (p_At_Id       => p_At_Id,
                                p_ndt_Id      => l_ndt_id,
                                p_file_code   => p_file_code);
        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'IK',
            p_At_St_New   => 'IP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');

        -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
        FOR xx IN (SELECT t.atk_at     AS at_id
                     FROM at_links t
                    WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
        LOOP
            Api$act.Set_At_St (
                p_At_Id       => xx.at_id,
                p_At_St_Old   => 'IK',
                p_At_St_New   => 'IP',
                --p_At_Action_Stop_Dt => SYSDATE,
                p_Log_Msg     => CHR (38) || '317',
                p_Wrong_St_Msg   =>
                    'Затвердження надавачем можливо лише в стані "Підписано отримувачем"');
        END LOOP;


        --Для всіх рішень по зверненню до якого привязаний акт з таким самим НСП
        l_qty := 0;

        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St = 'SP2'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус рішення
            Api$act.Approve_Act (Rec.Decision_Id);
            l_qty := l_qty + 1;
        END LOOP;

        -- #115754
        SELECT COUNT (*)
          INTO l_cnt
          FROM act  t
               JOIN act l
                   ON (    l.at_ap = t.at_ap
                       AND l.at_rnspm = t.at_rnspm
                       AND l.at_tp = 'IP'
                       AND l.at_st = 'IA')
         WHERE t.at_id = p_At_Id;

        --№115115
        IF l_qty = 0 AND (l_cnt IS NULL OR l_cnt = 0)
        THEN
            raise_application_error (
                -20000,
                'Не знайдено жодного рішення в статусі "Вторинну оцінку потреб виконано"');
        END IF;

        -- Це костиль, але зараз немає часу розбиратись, чому не відпрацювало  корректно
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'PDSP'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            CMES$CALENDAR.Init_Calendar_PDSP (Rec.Decision_Id);
        END LOOP;

        --Якщо це повторний розгляд ІП і договір в статусі DT то переводимо в статус діючий план
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND a.At_Rnspm = d.At_Rnspm
                              AND d.At_Tp = 'TCTR'
                              AND d.At_St = 'DT'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус інд. плану на "Діючий план"
            UPDATE Act a
               SET a.At_St = 'IT'
             WHERE a.At_Id = p_At_Id AND a.At_St = 'IP';

            IF SQL%ROWCOUNT = 1
            THEN
                Api$act.Write_At_Log (
                    p_Atl_At        => p_At_Id,
                    p_Atl_Hs        => Tools.Gethistsessioncmes (),
                    p_Atl_St        => 'IT',
                    p_Atl_Message   => CHR (38) || '158',
                    p_Atl_St_Old    => 'IP');
            END IF;
        END LOOP;

        Tools.Stop_Log_Ses_Id;
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
            p_At_St_Old      => 'IN',
            p_At_St_New      => 'ID',
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');

        -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
        FOR xx IN (SELECT t.atk_at     AS at_id
                     FROM at_links t
                    WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
        LOOP
            Api$act.Set_At_St (
                p_At_Id          => xx.at_id,
                p_At_St_Old      => 'IN',
                p_At_St_New      => 'ID',
                p_Log_Msg        => CHR (38) || '319#' || p_Reason,
                p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
        END LOOP;
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
              (    l_At_St = 'IV'
               AND Api$act.Signer_Exists (
                       p_Ati_At   => p_At_Id,
                       p_Ati_Sc   => Ikis_Rbm.Tools.Getcusc (l_Cu_Id),
                       p_Ati_Tp   => 'RC'))
           OR --Якщо стан акту "Підписано отримувачем" - дозволяемо змінювати стан, лише якщо поточний користувач має роль в кабінеті цього надавача
              (    l_At_St = 'IK'
               AND Cmes$act.Check_Act_Access_Pr (p_At_Id => p_At_Id))
        THEN
            UPDATE Act a
               SET a.At_St = 'IR'
             WHERE a.At_Id = p_At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => p_At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes (),
                p_Atl_St        => 'IR',
                p_Atl_Message   => CHR (38) || '231#' || p_Reason,
                p_Atl_St_Old    => NULL);

            -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
            FOR xx IN (SELECT t.atk_at     AS at_id
                         FROM at_links t
                        WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
            LOOP
                UPDATE Act a
                   SET a.At_St = 'IR'
                 WHERE a.At_Id = xx.at_id;

                Api$act.Write_At_Log (
                    p_Atl_At        => xx.at_id,
                    p_Atl_Hs        => Tools.Gethistsessioncmes (),
                    p_Atl_St        => 'IR',
                    p_Atl_Message   => CHR (38) || '318#' || p_Reason,
                    p_Atl_St_Old    => NULL);
            END LOOP;
        ELSE
            Raise_Application_Error (
                -20000,
                'Відхилення в поточному стані неможливо');
        END IF;
    END;


    -----------------------------------------------------------
    -- АРХІВУВАННЯ ПОТОЧНОГО ДІЮЧОГО ПЛАНУ ДЛЯ КОРЕКЦІЇ (КМа)
    -----------------------------------------------------------
    PROCEDURE Set_Archive_Cm (p_At_Id IN NUMBER, p_Reason IN VARCHAR2)
    IS
    BEGIN
        Write_Audit ('Set_Archive_Cm');

        Api$act.Set_At_St (
            p_At_Id               => p_At_Id,
            p_At_St_Old           => 'IT',
            p_At_St_New           => 'IA',
            p_At_Action_Stop_Dt   => SYSDATE,
            p_Log_Msg             => CHR (38) || '157',
            p_Wrong_St_Msg        =>
                'Відправка плану на повторний розгляд доступно в стані діючого плану!');


        --Для АВОП який пов`язаний з ІП переводимо також в статус архівовано
        FOR Rec
            IN (SELECT d.At_Id     AS avop_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Main_Link = d.At_Id
                              AND a.at_main_link_tp = 'AVOP'
                              AND d.At_St = 'VP'
                 WHERE a.At_Id = p_At_Id)
        LOOP
            --Змінюємо статус рішення
            Api$act.Set_At_St (
                p_At_Id       => Rec.Avop_Id,
                p_At_St_Old   => 'VP',
                p_At_St_New   => 'VA',
                p_Log_Msg     => CHR (38) || '157#' || p_Reason,
                p_Wrong_St_Msg   =>
                    'Відправка акту вторинної оцінки потреб на повторний розгляд доступно лише в стані діючого плану!');
        END LOOP;

        -- перевід статусу для всіх дочірніх ІПів разом з головним ІПом
        FOR xx IN (SELECT t.atk_at     AS at_id
                     FROM at_links t
                    WHERE t.atk_link_at = p_At_Id AND t.atk_tp = 'IP')
        LOOP
            Api$act.Set_At_St (
                p_At_Id               => xx.at_id,
                p_At_St_Old           => 'IT',
                p_At_St_New           => 'IA',
                p_At_Action_Stop_Dt   => SYSDATE,
                p_Log_Msg             => CHR (38) || '320',
                p_Wrong_St_Msg        =>
                    'Відправка плану на повторний розгляд доступно в стані діючого плану!');


            --Для АВОП який пов`язаний з ІП переводимо також в статус архівовано
            FOR Rec
                IN (SELECT d.At_Id     AS avop_Id
                      FROM Act  a
                           JOIN Act d
                               ON     a.At_Main_Link = d.At_Id
                                  AND a.at_main_link_tp = 'AVOP'
                                  AND d.At_St = 'VP'
                     WHERE a.At_Id = xx.at_id)
            LOOP
                --Змінюємо статус рішення
                Api$act.Set_At_St (
                    p_At_Id       => Rec.Avop_Id,
                    p_At_St_Old   => 'VP',
                    p_At_St_New   => 'VA',
                    p_Log_Msg     => CHR (38) || '320#' || p_Reason,
                    p_Wrong_St_Msg   =>
                        'Відправка акту вторинної оцінки потреб на повторний розгляд доступно лише в стані діючого плану!');
            END LOOP;
        END LOOP;
    END;

    -----------------------------------------------------------
    --     СТВОРЕННЯ ОСНОВНОГО ІП (ЯКЩО БІЛЬШЕ 1 ПОСЛУГИ)
    -----------------------------------------------------------

    PROCEDURE get_united_form_file (p_at_id       IN     NUMBER,
                                    p_doc_cur        OUT SYS_REFCURSOR,
                                    p_files_cur      OUT SYS_REFCURSOR)
    IS
        l_Cnt              NUMBER;
        l_Cu_Id            NUMBER;
        l_At_St            VARCHAR2 (10);
        l_Atd_Id           NUMBER;
        l_Doc_Id           NUMBER;
        l_Dh_Id            NUMBER;
        l_File_Code        VARCHAR2 (50);
        l_File_Hash        VARCHAR2 (50);
        l_atd_attach_src   VARCHAR2 (50);
    BEGIN
        Write_Audit ('get_united_form_file');
        Check_Act_Access (p_At_Id);

          SELECT a.At_St, COUNT (*)
            INTO l_At_St, l_cnt
            FROM Act a
           WHERE     a.At_Id = p_At_Id
                 AND a.at_main_link_tp = 'DECISION'
                 AND a.at_tp = 'IP'
        GROUP BY a.at_st;

        IF (l_cnt < 1)
        THEN
            raise_application_error (
                -20000,
                'Переданий акт не являється об`єднаним ІП!');
        END IF;

        SELECT MAX (d.Atd_Id),
               MAX (d.Atd_Doc),
               MAX (d.Atd_Dh),
               MAX (atd_attach_src)
          INTO l_Atd_Id,
               l_Doc_Id,
               l_Dh_Id,
               l_atd_attach_src
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = 1022
               AND d.History_Status = 'A';

        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        IF l_Atd_Id IS NULL
        THEN
            Uss_Doc.Api$documents.Save_Document (
                p_Doc_Id          => NULL,
                p_Doc_Ndt         => 1022,
                p_Doc_Actuality   => 'U',
                p_New_Id          => l_Doc_Id);

            Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                                 p_Dh_Doc         => l_Doc_Id,
                                                 p_Dh_Sign_Alg    => NULL,
                                                 p_Dh_Ndt         => 1022,
                                                 p_Dh_Sign_File   => NULL,
                                                 p_Dh_Actuality   => 'U',
                                                 p_Dh_Dt          => SYSDATE,
                                                 p_Dh_Wu          => NULL,
                                                 p_Dh_Src         => 'CMES',
                                                 p_Dh_Cu          => l_Cu_Id,
                                                 p_New_Id         => l_Dh_Id);



            INSERT INTO At_Document (Atd_Id,
                                     Atd_At,
                                     Atd_Ndt,
                                     Atd_Doc,
                                     Atd_Dh,
                                     History_Status,
                                     atd_attach_src)
                 VALUES (0,
                         p_At_Id,
                         1022,
                         l_Doc_Id,
                         l_Dh_Id,
                         'A',
                         'AUTO')
              RETURNING Atd_Id
                   INTO l_Atd_Id;

            l_atd_attach_src := 'AUTO';
        ELSE
            BEGIN
                SELECT File_Code, File_Hash
                  INTO l_File_Code, l_File_Hash
                  FROM (SELECT f.File_Code,
                               f.File_Hash,
                               NVL (a.dat_num, -1)                  dat_num,
                               NVL (MAX (a.dat_num) OVER (), -1)    max_dat_num
                          FROM Uss_Doc.v_Doc_Attachments  a
                               JOIN Uss_Doc.v_Files f
                                   ON a.Dat_File = f.File_Id
                         WHERE a.Dat_Dh = l_Dh_Id)
                 WHERE dat_Num = max_dat_num;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    NULL;
            END;
        END IF;

        IF     l_At_St = 'IN'
           AND (   l_atd_attach_src IN ('AUTO', 'TABLET')
                OR l_atd_attach_src IS NULL)
        THEN
            OPEN p_files_cur FOR
                SELECT a.*
                  FROM at_links l JOIN act a ON (a.at_id = l.atk_at)
                 WHERE     l.atk_link_at = p_at_id
                       AND l.atk_tp = 'IP'
                       AND a.at_tp = 'IP'
                       AND a.at_st NOT IN ('IR', 'ID', 'IA');
        ELSE
            OPEN p_files_cur FOR
                SELECT a.*
                  FROM at_links l JOIN act a ON (a.at_id = l.atk_at)
                 WHERE 1 = 2;
        END IF;

        OPEN p_Doc_Cur FOR
            SELECT l_Atd_Id             AS Atd_Id,
                   1022                 AS Atd_Ndt,
                   l_Doc_Id             AS Atd_Doc,
                   l_Dh_Id              AS Atd_Dh,
                   l_File_Code          AS File_Code,
                   l_File_Hash          AS File_Hash,
                   NULL                 AS File_Content,
                   l_atd_attach_src     AS Atd_Attach_Src
              FROM DUAL;
    END;

    PROCEDURE Create_Main_Ip (p_at_id IN NUMBER, p_new_id OUT NUMBER)
    IS
        l_pdsp_id   NUMBER;
        l_ss_cnt    NUMBER := get_ss_cnt (p_at_id);
        l_cnt1      NUMBER;
        l_cnt2      NUMBER;
        l_act       act%ROWTYPE;
        l_Cu_Id     NUMBER := ikis_rbm.tools.GetCurrentCu;
        l_dt1       DATE;
        l_dt2       DATE;
    BEGIN
        /* Write_Audit('Create_Main_Ip');
         Check_Act_Access(p_At_Id);*/

        IF (l_ss_cnt < 2)
        THEN
            raise_application_error (
                -20000,
                   'В рішенні надається всього '
                || l_ss_cnt
                || ' послуга, створення головного ІП не потрібно!');
        END IF;

        SELECT       --count(case when a.at_st = 'IO' then 1 end) as done_cnt,
               COUNT (*)     AS all_cnt,
               MAX (t.atk_link_at),
               MIN (a.at_action_start_dt),
               MAX (a.at_action_stop_dt)
          INTO                                                    /*l_cnt1, */
               l_cnt2,
               l_pdsp_id,
               l_dt1,
               l_dt2
          FROM at_links  t
               JOIN at_links h ON (h.atk_link_at = t.atk_link_at)
               JOIN act a ON (a.at_id = h.atk_at)
         WHERE     t.atk_at = p_at_id
               AND t.atk_tp = 'DECISION'
               AND a.at_tp = 'IP'
               AND a.at_st NOT IN ('IR', 'ID', 'IA');

        IF (l_ss_cnt != l_cnt2)
        THEN
            raise_application_error (
                -20000,
                'Не для всіх послуг створено дочірні ІПи!');
        END IF;

        SELECT MAX (at_id)
          INTO l_cnt1
          FROM act t
         WHERE     t.at_main_link = l_pdsp_id
               AND t.at_main_link_tp = 'DECISION'
               AND t.at_tp = 'IP'
               AND at_st NOT IN ('IR', 'ID', 'IA');

        IF (l_cnt1 IS NOT NULL AND l_cnt1 > 0)
        THEN
            p_new_id := l_cnt1;
            RETURN;
        END IF;


        /*if (l_cnt1 < l_ss_cnt or l_cnt1 is null) then
          raise_application_error(-20000, 'Не всі дочірні ІПи затверджені ( '|| l_cnt1 || '/' || l_ss_cnt || ' ). Будь-ласка, затвердіть їх до того як створити головний ІП.');
        end if;*/

        SELECT *
          INTO l_act
          FROM act t
         WHERE t.at_id = p_at_id;

        Api$act.Save_Act (p_At_Id                => NULL,
                          p_At_Tp                => 'IP',
                          p_At_Pc                => l_Act.At_Pc,
                          p_At_Num               => NULL,
                          p_At_Dt                => TRUNC (SYSDATE),
                          p_At_Org               => l_Act.At_Org,
                          p_At_Sc                => l_Act.At_Sc,
                          p_At_Rnspm             => l_Act.At_Rnspm,
                          p_At_Rnp               => NULL,
                          p_At_Ap                => l_Act.At_Ap,
                          p_At_St                => 'IN',
                          p_At_Src               => 'CMES',
                          p_At_Main_Link_Tp      => 'DECISION',
                          p_At_Main_Link         => l_pdsp_id,
                          p_At_Action_Start_Dt   => l_dt1,
                          p_At_Action_Stop_Dt    => l_dt2,
                          p_At_Notes             => l_Act.At_Notes,
                          p_At_Live_Address      => l_Act.At_Live_Address,
                          p_At_Cu                => l_Cu_Id,
                          p_At_Case_Class        => l_Act.At_Case_class,
                          p_New_Id               => p_new_id);

        INSERT INTO at_service (ats_id,
                                ats_at,
                                ats_nst,
                                history_status,
                                ats_at_src,
                                ats_st,
                                ats_ss_method,
                                ats_ss_address_tp,
                                ats_ss_address,
                                ats_tarif_sum,
                                ats_act_sum,
                                ats_hs_decision,
                                ats_rnspa)
            SELECT 0,
                   p_new_id,
                   t.ats_nst,
                   'A',
                   t.ats_at_src,
                   t.ats_st,
                   t.ats_ss_method,
                   t.ats_ss_address_tp,
                   t.ats_ss_address,
                   t.ats_tarif_sum,
                   t.ats_act_sum,
                   t.ats_hs_decision,
                   t.ats_rnspa
              FROM at_service t
             WHERE     t.ats_at = l_pdsp_id
                   AND t.ats_st IN ('P', 'SG')
                   AND t.ats_ss_term = 'P'
                   AND t.ats_nst NOT IN (401, 403, 420)
                   AND t.history_status = 'A';

        INSERT INTO at_person q (atp_at,
                                 atp_sc,
                                 atp_fn,
                                 atp_mn,
                                 atp_ln,
                                 atp_birth_dt,
                                 atp_relation_tp,
                                 atp_is_disabled,
                                 atp_is_capable,
                                 atp_work_place,
                                 atp_is_adr_matching,
                                 atp_phone,
                                 atp_notes,
                                 atp_live_address,
                                 atp_tp,
                                 atp_cu,
                                 atp_app_tp,
                                 atp_fact_address,
                                 history_status,
                                 atp_is_disordered,
                                 atp_disable_record,
                                 atp_capable_record,
                                 atp_disorder_record,
                                 atp_sex,
                                 atp_citizenship,
                                 atp_is_selfservice,
                                 atp_is_vpo,
                                 atp_is_orphan,
                                 atp_email,
                                 atp_app,
                                 atp_num)
            SELECT p_new_id,
                   t.atp_sc,
                   t.atp_fn,
                   t.atp_mn,
                   t.atp_ln,
                   t.atp_birth_dt,
                   t.atp_relation_tp,
                   t.atp_is_disabled,
                   t.atp_is_capable,
                   t.atp_work_place,
                   t.atp_is_adr_matching,
                   t.atp_phone,
                   t.atp_notes,
                   t.atp_live_address,
                   t.atp_tp,
                   t.atp_cu,
                   t.atp_app_tp,
                   t.atp_fact_address,
                   'A',
                   t.atp_is_disordered,
                   t.atp_disable_record,
                   t.atp_capable_record,
                   t.atp_disorder_record,
                   t.atp_sex,
                   t.atp_citizenship,
                   t.atp_is_selfservice,
                   t.atp_is_vpo,
                   t.atp_is_orphan,
                   t.atp_email,
                   t.atp_app,
                   t.atp_num
              FROM at_person t
             WHERE t.atp_at = p_at_id                              --l_pdsp_id
                                      AND t.history_status = 'A';

        FOR xx
            IN (SELECT a.*
                  FROM at_links t JOIN act a ON (a.at_id = t.atk_at)
                 WHERE     t.atk_tp = 'DECISION'
                       AND t.atk_link_at = l_pdsp_id
                       AND a.at_tp = 'IP'
                       AND a.at_st NOT IN ('ID', 'IR', 'IA'))
        LOOP
            Api$act.Save_Link (p_Atk_At        => xx.at_id,
                               p_Atk_Link_At   => p_new_id,
                               p_Atk_Tp        => 'IP');
        END LOOP;
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
END Cmes$act_Ip;
/