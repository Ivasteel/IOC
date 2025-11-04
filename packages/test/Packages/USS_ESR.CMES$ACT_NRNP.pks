/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_NRNP
IS
    -- Author  : BOGDAN
    -- Created : 07.08.2024 18:04:57
    -- Purpose : «Наказ/розпорядження про надання соціальних послуг»

    Pkg                        VARCHAR2 (50) := 'CMES$ACT_NRNP';

    c_Nrnp_Form_Ndt   CONSTANT NUMBER := 1019;

    TYPE r_Act IS RECORD
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

    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        -- p_At_Attrs     IN CLOB,
                        p_At_Services    IN     CLOB,
                        p_At_Signers     IN     CLOB);

    FUNCTION Get_Attr_Val_String (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

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

    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Pers_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR,
                            p_Services_Cur        OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_File (p_At_Id       IN     NUMBER,
                             p_Atd_Dh         OUT NUMBER,
                             p_File_Code      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id                  IN     NUMBER,
                             p_Atd_Dh                    OUT NUMBER,
                             p_File_Code                 OUT VARCHAR2,
                             p_File_Signs_Code_List      OUT VARCHAR2);

    PROCEDURE Get_Form_File (p_At_Id IN NUMBER, p_Doc_Cur OUT SYS_REFCURSOR);

    PROCEDURE Get_Form_Doc (p_At_Id IN NUMBER, p_Doc OUT SYS_REFCURSOR);

    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR);

    PROCEDURE Set_Signed_Pr (p_Atd_Id         NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    PROCEDURE Set_Declined (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END CMES$ACT_NRNP;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_NRNP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_NRNP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_NRNP
IS
    g_Nda_Map   Api$act.t_Nda_Map;

    PROCEDURE Write_Audit (p_Proc_Name IN VARCHAR2)
    IS
    BEGIN
        Tools.Writemsg (Pkg || '.' || p_Proc_Name);
    END;

    -----------------------------------------------------------
    --     ПЕРЕВІРКА ПРАВА ДОСТУПУ ДО АКТУ
    -----------------------------------------------------------
    PROCEDURE Check_Act_Access (p_At_Id IN NUMBER)
    IS
    BEGIN
        Cmes$act.Check_Act_Access (p_At_Id);
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
                   'Помилка парсингу договору: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    -----------------------------------------------------------
    -- МАПІНГ ПОЛІВ АКТУ ЩО ЗБЕРІГАЮТЬСЯ В АТРИБУТИ ДОКУМЕНТА
    -----------------------------------------------------------
    PROCEDURE Map_Nda2act
    IS
    BEGIN
        IF g_Nda_Map.COUNT > 0
        THEN
            RETURN;
        END IF;
    /*g_Nda_Map(3071) := 'At_Order_Doc_Name';
    g_Nda_Map(3073) := 'At_Order_Doc_Num';
    g_Nda_Map(3072) := 'At_Order_Doc_Dt';
    g_Nda_Map(3077) := 'At_Rnp_Info';*/
    END;

    -----------------------------------------------------------
    --        ОТРИМАННЯ ІД ДОКУМЕНТА
    -----------------------------------------------------------
    FUNCTION Get_Form_Doc (p_At_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Cu_Id    NUMBER;
        l_Atd_Id   NUMBER;
        l_Doc_Id   NUMBER;
        l_Dh_Id    NUMBER;
    BEGIN
        l_Cu_Id := Ikis_Rbm.Tools.Getcurrentcu;

        SELECT MAX (d.Atd_Id)
          INTO l_Atd_Id
          FROM At_Document d
         WHERE     d.Atd_At = p_At_Id
               AND d.Atd_Ndt = c_Nrnp_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => c_Nrnp_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (
            p_Dh_Id          => NULL,
            p_Dh_Doc         => l_Doc_Id,
            p_Dh_Sign_Alg    => NULL,
            p_Dh_Ndt         => c_Nrnp_Form_Ndt,
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
                                 History_Status)
             VALUES (0,
                     p_At_Id,
                     c_Nrnp_Form_Ndt,
                     l_Doc_Id,
                     l_Dh_Id,
                     'A')
          RETURNING Atd_Id
               INTO l_Atd_Id;

        RETURN l_Atd_Id;
    END;

    PROCEDURE Save_Services (p_At_Id NUMBER, p_Tctr_Id NUMBER)
    IS
    BEGIN
        --Видаляємо послуги яких немає в договорі
        UPDATE At_Service s
           SET s.History_Status = 'H'
         WHERE     s.Ats_At = p_At_Id
               AND s.History_Status = 'A'
               AND NOT EXISTS
                       (SELECT 1
                          FROM At_Service St
                         WHERE     St.Ats_At = p_Tctr_Id
                               AND St.Ats_Nst = s.Ats_Nst
                               AND st.history_status = 'A');

        INSERT INTO At_Service (Ats_Id,
                                Ats_At,
                                Ats_Nst,
                                History_Status)
            SELECT 0,
                   p_At_Id,
                   s.Ats_Nst,
                   'A'
              FROM At_Service  s
                   JOIN act t ON (t.at_id = s.ats_at)                  -- tctr
                   JOIN act p ON (p.at_id = t.at_main_link)             --pdsp
                   JOIN at_service sp
                       ON (sp.ats_at = p.at_id AND s.ats_nst = sp.ats_nst)
             WHERE     s.Ats_At = p_Tctr_Id
                   AND s.History_Status = 'A'
                   AND sp.History_Status = 'A'
                   --AND s.Ats_St NOT IN ('SU', 'ST')
                   AND sp.Ats_St IN ('SG') -- статуси змінюються лише в ПДСП. в договорі ні.
                   AND NOT EXISTS
                           (SELECT 1
                              FROM At_Service St
                             WHERE     St.Ats_At = p_At_Id
                                   AND St.Ats_Nst = s.Ats_Nst
                                   AND st.history_status = 'A');
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Persons     IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        --p_At_Attrs     IN CLOB,
                        p_At_Services    IN     CLOB,
                        p_At_Signers     IN     CLOB)
    IS
        l_Cu_Id       NUMBER;
        l_At_Cu       NUMBER;
        l_cnt         NUMBER;
        l_At_St_Old   VARCHAR2 (10);
        l_Act         r_Act;
        l_Persons     Api$act.t_At_Persons;
        l_Signers     Api$act.t_At_Signers;
        l_Documents   Api$act.t_At_Documents;
        l_Services    Api$act.t_At_Services;
        l_Atd_Id      NUMBER;
    --l_Attrs     Api$act.t_At_Document_Attrs;
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

            IF NVL (l_At_St_Old, '-') <> 'FN'
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування повідомлення в поточному статусі заборонено');
            END IF;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM Act a
         WHERE     a.At_Tp = 'NRNP'
               AND a.at_main_link = l_Act.At_Decision
               AND a.At_St NOT IN ('FD', 'FR')
               AND a.At_Id <> NVL (p_At_Id, -1);

        IF l_cnt > 0
        THEN
            Raise_Application_Error (
                -20000,
                'По цьому випадку вже існує акт про припинення надання СП');
        END IF;

        --ПАРСИНГ
        l_Persons := Api$act.Parse_Persons (p_At_Persons);
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Services := Api$act.Parse_Services (p_At_Services);

        --l_Attrs := Api$act.Parse_Attributes(p_At_Attrs);

        --#100266 Перевірка наявності посилання на файли в архиві
        FOR i IN 1 .. l_Documents.COUNT
        LOOP
            IF l_Documents (i).atd_doc IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Для документу кодом '
                    || l_Documents (i).atd_ndt
                    || ' не вказано посилання на файл в архіві');
            END IF;

            IF l_Documents (i).atd_dh IS NULL
            THEN
                Raise_Application_Error (
                    -20000,
                       'Для документу кодом '
                    || l_Documents (i).atd_ndt
                    || ' не вказано посилання версію історії файлу в архіві');
            END IF;
        END LOOP;

        API$ACT.CheckIsActSCInPersons (l_Act.At_Sc, l_Persons);

        Api$act.Save_Act (
            p_At_Id               => p_At_Id,
            p_At_Tp               => 'NRNP',
            p_At_Pc               => l_Act.At_Pc,
            p_At_Dt               => l_Act.At_Dt,
            p_At_Org              => l_Act.At_Org,
            p_At_Sc               => l_Act.At_Sc,
            p_At_Rnspm            => l_Act.At_Rnspm,
            p_At_Ap               => l_Act.At_Ap,
            p_At_St               => 'FN',
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
        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);
        Api$act.Save_Services (p_At_Id => p_At_Id, p_Services => l_Services);
        Api$act.Save_Signers (p_At_Id       => p_At_Id,
                              p_Signers     => l_Signers,
                              p_Persons     => l_Persons,
                              p_Documents   => l_Documents);

        --Map_Nda2act;
        --l_Atd_Id := Get_Form_Doc(p_At_Id);
        --Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);

        --Save_Services(p_At_Id => p_At_Id, p_Tctr_Id => l_Act.At_Tctr);

        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => 'FN',
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
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
                   api$act.Get_Atd_Attach_Source (a.at_id, c_Nrnp_Form_Ndt)
                       AS Atd_Attach_Source
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Nrnp_St s ON a.At_St = s.Dic_Value
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
            p_src      => 'USS_ESR.CMES$ACT_NRNP.Get_Acts_Cm',
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
             WHERE     a.At_Tp = 'NRNP'
                   AND (a.At_Cu = l_Cu_Id)
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
            p_src      => 'USS_ESR.CMES$ACT_NRNP.Get_Acts_Pr',
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
            Tools.LOG (p_src              => 'USS_ESR.CMES$ACT_NRNP.Get_Acts_Pr',
                       p_obj_tp           => 'CMES_OWNER_ID',
                       p_obj_id           => p_Cmes_Owner_Id,
                       p_regular_params   => 'Insufficient privileges.');
            Api$act.Raise_Unauthorized;
        END IF;

        DELETE FROM Tmp_Work_Ids;

        INSERT INTO Tmp_Work_Ids (x_Id)
            SELECT a.At_Id
              FROM Act a
             WHERE     a.At_Tp = 'NRNP'
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

        Tools.LOG (
            p_src      => 'USS_ESR.CMES$ACT_NRNP.Get_Acts_By_Ap',
            p_obj_tp   => 'CMES_OWNER_ID',
            p_obj_id   => p_Cmes_Owner_Id,
            p_regular_params   =>
                   'p_Ap_Id='
                || p_Ap_Id
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
                                               WHEN 'FR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'NRNP'
                               AND a.At_Rnspm = p_Cmes_Owner_Id
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'FD')
                 WHERE Rn = 1;
        ELSE
            l_Sc_Id := Ikis_Rbm.Tools.Getcusc (Ikis_Rbm.Tools.Getcurrentcu);

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT At_Id
                  FROM (SELECT a.At_Id,
                               ROW_NUMBER ()
                                   OVER (
                                       ORDER BY
                                           --#93662 + устна постановка ЖХ: якщо серед декількох актів є акт в стані "Відхилено" показуємо його в останню чергу
                                           CASE a.At_St
                                               WHEN 'FR' THEN 2
                                               ELSE 1
                                           END)    AS Rn
                          FROM Act a
                         WHERE     a.At_Ap = p_Ap_Id
                               AND a.At_Tp = 'NRNP'
                               --#93662 + устна постановка ЖХ: не показуємо акти в стаусі скасовано
                               AND a.At_St <> 'FD'
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
                                               AND l.Atl_St IN ('FV')))
                 WHERE Rn = 1;
        END IF;

        Get_Act_List (p_Acts);
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        --Map_Nda2act;
        --Api$act.Get_Attributes(p_At_Id => p_At_Id, p_Atd_Ndt => c_Nrnp_Form_Ndt, p_Nda_Map => g_Nda_Map, p_Res => p_Res);

        OPEN p_Res FOR
            SELECT a.*, n.Nda_Name AS Atda_Nda_Name
              FROM At_Document_Attr  a
                   JOIN Uss_Ndi.v_Ndi_Document_Attr n
                       ON a.Atda_Nda = n.Nda_Id
             WHERE a.Atda_At = p_At_Id AND a.History_Status = 'A';
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => c_Nrnp_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
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

    ----------------------------------------------------------
    --   ОТРИМАННЯ ПІБ законного представника / уповноваженої особи ОСП
    -----------------------------------------------------------
    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (300);
    BEGIN
        SELECT MAX (Uss_Person.Api$sc_Tools.Get_Pib (p.App_Sc))
          INTO l_Result
          FROM Ap_Person p
         WHERE     p.App_Ap = p_Ap_Id
               AND p.App_Tp = 'Z'
               AND NOT EXISTS
                       (SELECT 1
                          FROM Ap_Person Pp
                         WHERE     Pp.App_Ap = p_Ap_Id
                               AND Pp.History_Status = 'A'
                               AND Pp.App_Tp = 'OS');

        RETURN l_Result;
    END;

    FUNCTION Get_Attr_Val_String (p_At_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR (4000);
    BEGIN
        SELECT MAX (a.atda_val_string)
          INTO l_res
          FROM At_Document_Attr a
         WHERE     a.Atda_At = p_At_Id
               AND a.atda_nda = p_Nda_Id
               AND a.History_Status = 'A';

        RETURN l_res;
    END;

    -----------------------------------------------------------
    --   ОТРИМАННЯ ОСНОВНИХ ДАНИХ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT at_id,
                   at_tp,
                   at_pc,
                   --#112205
                    (SELECT MAX (z.atda_val_string)
                       FROM at_document_attr z
                      WHERE     z.atda_at = a.at_id
                            AND z.history_status = 'A'
                            AND z.atda_nda = 3268)
                       at_num,
                   (SELECT MAX (z.atda_val_dt)
                      FROM at_document_attr z
                     WHERE     z.atda_at = a.at_id
                           AND z.history_status = 'A'
                           AND z.atda_nda = 3288)
                       at_dt,
                   at_org,
                   at_sc,
                   at_rnspm,
                   at_rnp,
                   at_ap,
                   at_st,
                   at_src,
                   at_case_class,
                   at_main_link_tp,
                   at_main_link,
                   at_action_start_dt,
                   at_action_stop_dt,
                   at_notes,
                   at_family_info,
                   at_live_address,
                   at_wu,
                   at_cu,
                   at_conclusion_tp,
                   at_form_tp,
                   at_redirect_rnspm,
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
                   api$act.Get_Atd_Attach_Source (a.at_id, c_Nrnp_Form_Ndt)
                       AS Atd_Attach_Source,
                   (SELECT MAX (
                               p.atp_ln || ' ' || p.atp_fn || ' ' || p.atp_mn)
                      FROM at_person p
                     WHERE     p.atp_at = a.at_id
                           AND (p.atp_sc = a.at_sc OR a.at_sc IS NULL)
                           AND p.history_status = 'A')
                       AS act_main_pib,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   (SELECT MAX (z.atda_val_dt)
                      FROM at_document_attr z
                     WHERE     z.atda_at = a.at_id
                           AND z.history_status = 'A'
                           AND z.atda_nda = 3301)
                       AS Expiration_Dt          -- "Дата закінчення терміну",
              /*
             (SELECT max(z.atda_val_string)
                 FROM at_document_attr z
                where z.atda_at = a.at_id
                  and z.history_status = 'A'
                  and z.atda_nda = 3268
              ) as at_prescript_num, -- "Номер розпорядчого документу"
             (SELECT max(z.atda_val_dt)
                 FROM at_document_attr z
                where z.atda_at = a.at_id
                  and z.history_status = 'A'
                  and z.atda_nda = 3288
              ) as at_prescript_dt -- "Дата розпорядчого документу"
              */
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Nrnp_St s ON a.At_St = s.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Uss_Ndi.v_Ddn_At_Conclusion_Tp c
                       ON a.At_Conclusion_Tp = c.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ddn_Case_Class Cc
                       ON a.At_Case_Class = Cc.Dic_Value
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Pers_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR,
                            p_Services_Cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Api$Act.Check_At_Tp (p_At_Id, 'NRNP');

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Persons (p_At_Id, p_Pers_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Docs_Files_Cur);
        Get_Attributes (p_At_Id => p_At_Id, p_Res => p_Attrs_Cur);
        Get_Services (p_At_Id, p_Services_Cur);
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
            p_Form_Ndt    => Api$act.Define_Print_Form_Ndt (p_At_Id),
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
    BEGIN
        Write_Audit ('Get_Form_File');
        Check_Act_Access (p_At_Id);

        Api$act.Get_Form_File (
            p_At_Id                  => p_At_Id,
            p_Form_Ndt               => Api$act.Define_Print_Form_Ndt (p_At_Id),
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
        Check_Act_Access (p_At_Id);

        l_Ndt_Id := 1019; --Api$act.Define_Print_Form_Ndt(p_At_Id, l_Build_Proc);
        /*Api$act.Get_Form_File(p_At_Id           => p_At_Id,
                              p_At_Prj_St       => 'FN',
                              p_Form_Ndt        => l_Ndt_Id,
                              p_Form_Build_Proc => l_Build_Proc,
                              p_Doc_Cur         => p_Doc_Cur);*/
        Api$act.Get_Form_Doc (p_At_Id     => p_At_Id,
                              p_Atd_Ndt   => l_Ndt_Id,
                              p_Doc       => p_Doc_Cur);
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
            p_Atd_Ndt   => Api$act.Define_Print_Form_Ndt (p_At_Id),
            p_Doc       => p_Doc);
    END;

    -----------------------------------------------------------
    -- "ВІДПРАВКА" АКТУ НАДАВАЧУ НА ПІДПИС
    -----------------------------------------------------------
    PROCEDURE Send_To_Pr (p_At_Id NUMBER, p_Messages OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Send_To_Pr');
        Check_Act_Access (p_At_Id);

        --Виконуємо зміну статуса лише у разі, якщо проект акту пройшов всі контролі
        IF Api$act_Validation.Validate_Act (p_At_Id, p_Messages)
        THEN
            Api$act.Set_At_St (
                p_At_Id       => p_At_Id,
                p_At_St_Old   => 'FN',
                p_At_St_New   => 'FV',
                p_Log_Msg     => CHR (38) || '252',
                p_Wrong_St_Msg   =>
                    'Відправка інформації надавачу можлива лише в стані проекту');
        END IF;
    END;

    -----------------------------------------------------------
    -- ЗБЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ НСП
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Pr (p_Atd_Id         NUMBER,
                             p_file_code   IN VARCHAR2 DEFAULT NULL)
    IS
        l_At_Id        NUMBER;
        l_At_Rstopss   NUMBER;
        l_Ap_Id        NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        l_At_Id := Api$act.Get_Atd_At (p_Atd_Id);
        Cmes$act.Set_Signed_Pr (p_At_Id       => l_At_Id,
                                p_Atd_Id      => p_Atd_Id,
                                p_file_code   => p_file_code);

        Api$act.Set_At_St (
            p_At_Id       => l_At_Id,
            p_At_St_Old   => 'FV',
            p_At_St_New   => 'FP',
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Очікує підписання"');

        --109860
        FOR Rec
            IN (SELECT d.At_Id     AS Decision_Id
                  FROM Act  a
                       JOIN Act d
                           ON     a.At_Ap = d.At_Ap
                              AND d.At_Tp = 'PDSP'
                              AND d.At_St IN ('SA', 'O.SA')
                 WHERE a.At_Id = l_At_Id)
        LOOP
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
            p_At_St_Old      => 'FN',
            p_At_St_New      => 'FD',
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


        IF NOT Cmes$act.Check_Act_Access_Pr (p_At_Id)
        THEN
            Raise_Application_Error (
                -20000,
                'Відхилення може виконувати лише надавач соц. послуг');
        END IF;

        Api$act.Set_At_St (
            p_At_Id       => p_At_Id,
            p_At_St_Old   => 'FV',
            p_At_St_New   => 'FR',
            p_Log_Msg     => CHR (38) || '231#' || p_Reason,
            p_Wrong_St_Msg   =>
                'Відхилити можливо лише в стані "Очікує підписання"');
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
BEGIN
    NULL;
END CMES$ACT_NRNP;
/