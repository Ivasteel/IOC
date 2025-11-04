/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CMES$ACT_ISNP
IS
    -- Author  : SHOSTAK
    -- Created : 05.12.2023 11:22:28 AM
    -- Purpose : Інформація про призупинення надання соціальних послуг
    -- #91891

    Pkg                          VARCHAR2 (50) := 'CMES$ACT_ISNP';

    c_At_Tp             CONSTANT VARCHAR2 (10) := 'ISNP';
    c_At_Tp_Name        CONSTANT VARCHAR2 (1000)
        := 'інформації про призупинення надання соціальних послуг' ;

    c_At_St_Prj         CONSTANT VARCHAR2 (10) := 'TN';
    c_At_St_Canceled    CONSTANT VARCHAR2 (10) := 'TD';
    c_At_St_Sign_Pr     CONSTANT VARCHAR2 (10) := 'TV';
    c_At_St_Signed_CM   CONSTANT VARCHAR2 (10) := 'TP';
    c_At_St_Signed_Pr   CONSTANT VARCHAR2 (10) := 'TP';

    c_Form_Ndt          CONSTANT NUMBER := 849;
    с_Order_Ndt        CONSTANT NUMBER := 1008;

    TYPE r_Act IS RECORD
    (
        At_Pc                 Act.At_Pc%TYPE,
        At_Dt                 TIMESTAMP,
        At_Org                Act.At_Org%TYPE,
        At_Sc                 Act.At_Sc%TYPE,
        At_Rnspm              Act.At_Rnspm%TYPE,
        At_Action_Start_Dt    Act.At_Action_Start_Dt%TYPE,
        At_Action_Stop_Dt     Act.At_Action_Stop_Dt%TYPE,
        At_Live_Address       Act.At_Live_Address%TYPE,
        At_Tctr               NUMBER
    );

    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        p_At_Attrs       IN     CLOB,
                        p_At_Signers     IN     CLOB);

    FUNCTION Get_Agent_Pib (p_Ap_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Acts_By_Tctr (
        p_Tctr_Id         IN     NUMBER,
        p_Cmes_Owner_Id   IN     NUMBER,
        p_At_Dt_Start     IN     DATE DEFAULT NULL,
        p_At_Dt_Stop      IN     DATE DEFAULT NULL,
        p_At_Num          IN     VARCHAR2 DEFAULT NULL,
        p_At_Src          IN     VARCHAR2 DEFAULT NULL,
        p_At_Spec_Name    IN     VARCHAR2 DEFAULT NULL,
        p_Need_Sign       IN     VARCHAR2 DEFAULT NULL,
        p_Acts               OUT SYS_REFCURSOR,
        p_Attrs              OUT SYS_REFCURSOR);

    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR);

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

    --PROCEDURE Set_Signed_Pr(p_Atd_Id NUMBER,
    --                        p_file_code IN VARCHAR2 DEFAULT NULL);
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR);

    PROCEDURE Set_Canceled (p_At_Id IN NUMBER, p_Reason IN VARCHAR2);

    FUNCTION Check_File_Access (p_File_Code IN VARCHAR2, p_Cmes_Id IN NUMBER --Ignore
                                                                            )
        RETURN VARCHAR2;
END Cmes$act_Isnp;
/


GRANT EXECUTE ON USS_ESR.CMES$ACT_ISNP TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.CMES$ACT_ISNP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CMES$ACT_ISNP
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

        /*g_Nda_Map(5355) := 'At_Order_Doc_Name';
        g_Nda_Map(5356) := 'At_Order_Doc_Num';
        g_Nda_Map(5357) := 'At_Order_Doc_Dt';*/
        g_Nda_Map (5358) := 'At_Med_Conclusion_Dt';
        g_Nda_Map (5359) := 'At_Med_Conclusion_Num';
        g_Nda_Map (5360) := 'At_Med_Contraindications'; --todo: уточнити щодо довідника
    --ймовірно потрібно буде ще додати адресу для листування?

    -- #103636
    /*g_Nda_Map(8461) := 'At_Head_Position';
    g_Nda_Map(8459) := 'At_Head_Ln';
    g_Nda_Map(8460) := 'At_Head_Fn';*/
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
               AND d.Atd_Ndt = c_Form_Ndt
               AND d.History_Status = 'A';

        IF l_Atd_Id IS NOT NULL
        THEN
            RETURN l_Atd_Id;
        END IF;

        Uss_Doc.Api$documents.Save_Document (p_Doc_Id          => NULL,
                                             p_Doc_Ndt         => c_Form_Ndt,
                                             p_Doc_Actuality   => 'U',
                                             p_New_Id          => l_Doc_Id);

        Uss_Doc.Api$documents.Save_Doc_Hist (p_Dh_Id          => NULL,
                                             p_Dh_Doc         => l_Doc_Id,
                                             p_Dh_Sign_Alg    => NULL,
                                             p_Dh_Ndt         => c_Form_Ndt,
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
                     c_Form_Ndt,
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
                               AND St.Ats_Nst = s.Ats_Nst);

        INSERT INTO At_Service (Ats_Id,
                                Ats_At,
                                Ats_Nst,
                                History_Status)
            SELECT 0,
                   p_At_Id,
                   s.Ats_Nst,
                   'A'
              FROM At_Service s
             WHERE     s.Ats_At = p_Tctr_Id
                   AND s.History_Status = 'A'
                   AND s.Ats_St = 'SG';
    END;

    -----------------------------------------------------------
    --            ЗБЕРЕЖЕННЯ АКТУ
    -----------------------------------------------------------
    PROCEDURE Save_Act (p_At_Id          IN OUT NUMBER,
                        p_At_Src         IN     VARCHAR2,
                        p_Act            IN     CLOB,
                        p_At_Documents   IN     CLOB,
                        p_At_Attrs       IN     CLOB,
                        p_At_Signers     IN     CLOB)
    IS
        l_Cu_Id       NUMBER;
        l_At_Cu       NUMBER;
        l_At_St_Old   VARCHAR2 (10);
        l_Act         r_Act;
        l_Signers     Api$act.t_At_Signers;
        l_Persons     Api$act.t_At_Persons := Api$act.t_At_Persons ();
        l_Documents   Api$act.t_At_Documents;
        l_Atd_Id      NUMBER;
        l_Attrs       Api$act.t_At_Document_Attrs;
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

        IF     l_Act.At_Tctr IS NOT NULL
           AND l_Act.At_Rnspm <> Api$act.Get_At_Rnspm (l_Act.At_Tctr)
        THEN
            Raise_Application_Error (-20000,
                                     'Вказано договір по іншому надавачу');
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

            IF NVL (l_At_St_Old, '-') <> c_At_St_Prj
            THEN
                Raise_Application_Error (
                    -20000,
                    'Редагування в поточному статусі заборонено');
            END IF;
        END IF;

        --ПАРСИНГ
        l_Documents := Api$act.Parse_Documents (p_At_Documents);
        l_Signers := Api$act.Parse_Signers (p_At_Signers);
        l_Attrs := Api$act.Parse_Attributes (p_At_Attrs);

        Api$act.Save_Act (p_At_Id                => p_At_Id,
                          p_At_Tp                => c_At_Tp,
                          p_At_Pc                => l_Act.At_Pc,
                          p_At_Ap                => NULL,
                          p_At_Num               => NULL,
                          p_At_Dt                => l_Act.At_Dt,
                          p_At_Org               => l_Act.At_Org,
                          p_At_Sc                => l_Act.At_Sc,
                          p_At_Rnspm             => l_Act.At_Rnspm,
                          p_At_Action_Start_Dt   => l_Act.At_Action_Start_Dt,
                          p_At_Action_Stop_Dt    => l_Act.At_Action_Stop_Dt,
                          p_At_Live_Address      => l_Act.At_Live_Address,
                          p_At_Notes             => NULL,
                          p_At_St                => c_At_St_Prj,
                          p_At_Src               => p_At_Src,
                          p_At_Main_Link_Tp      => 'TCTR',
                          p_At_Main_Link         => l_Act.At_Tctr,
                          p_At_Cu                => l_Cu_Id,
                          p_New_Id               => p_At_Id);


        Api$act.Save_Documents (p_At_Id          => p_At_Id,
                                p_At_Documents   => l_Documents);
        Api$act.Save_Signers (p_At_Id       => p_At_Id,
                              p_Signers     => l_Signers,
                              p_Persons     => l_Persons,
                              p_Documents   => l_Documents);

        /*Map_Nda2act;
        l_Atd_Id := Get_Form_Doc(p_At_Id);
        Api$act.Save_Attributes(p_At_Id => p_At_Id, p_Atd_Id => l_Atd_Id, p_Attrs => l_Attrs, p_Nda_Map => g_Nda_Map);
      */
        Save_Services (p_At_Id => p_At_Id, p_Tctr_Id => l_Act.At_Tctr);


        Api$act.Write_At_Log (p_Atl_At        => p_At_Id,
                              p_Atl_Hs        => Tools.Gethistsessioncmes,
                              p_Atl_St        => c_At_St_Prj,
                              p_Atl_Message   => CHR (38) || '226',
                              p_Atl_St_Old    => NULL);
    END;

    -----------------------------------------------------------
    --ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ(ПОПЕРЕДНЬО ВІДФІЛЬТРОВАНИХ)
    -----------------------------------------------------------
    PROCEDURE Get_Act_List (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано форму ведення випадку
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   Api$act.Get_Signer_Position (a.At_Id, 'PR')
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,                         --todo: уточнити
                   --ІД договору
                   Tt.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   Tt.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   Tt.At_Dt
                       AS At_Tctr_Dt,
                   --Дата початку призупинення надання СП
                   a.At_Action_Start_Dt,
                   --Дата закінчення призупинення надання СП
                   a.At_Action_Stop_Dt,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   api$act.Get_Attr_Val_Dt (a.at_id, 5358)
                       AS At_Med_Conclusion_Dt,
                   api$act.Get_Attr_Val_Str (a.at_id, 5359)
                       AS At_Med_Conclusion_Num,
                   api$act.Get_Attr_Val_Str (a.at_id, 5360)
                       AS At_Med_Contraindications
              FROM Tmp_Work_Ids  t
                   JOIN Act a ON t.x_Id = a.At_Id
                   JOIN Uss_Ndi.v_Ddn_At_Isnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Act Tt ON a.At_Main_Link = Tt.At_Id;
    END;

    PROCEDURE Get_Attributes (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_At_Id     => p_At_Id,
                                p_Atd_Ndt   => c_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    PROCEDURE Get_Attributes (p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        Map_Nda2act;
        Api$act.Get_Attributes (p_Atd_Ndt   => c_Form_Ndt,
                                p_Nda_Map   => g_Nda_Map,
                                p_Res       => p_Res);
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ПЕРЕЛІКУ АКТІВ ЗА ДОГОВОРОМ
    -----------------------------------------------------------
    PROCEDURE Get_Acts_By_Tctr (
        p_Tctr_Id         IN     NUMBER,
        p_Cmes_Owner_Id   IN     NUMBER,
        p_At_Dt_Start     IN     DATE DEFAULT NULL,
        p_At_Dt_Stop      IN     DATE DEFAULT NULL,
        p_At_Num          IN     VARCHAR2 DEFAULT NULL,
        p_At_Src          IN     VARCHAR2 DEFAULT NULL,
        p_At_Spec_Name    IN     VARCHAR2 DEFAULT NULL,
        p_Need_Sign       IN     VARCHAR2 DEFAULT NULL,
        p_Acts               OUT SYS_REFCURSOR,
        p_Attrs              OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Acts_By_Tctr');

        DELETE FROM Tmp_Work_Ids;

        IF     p_Cmes_Owner_Id IS NOT NULL
           AND (   Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_SPEC')
                OR Ikis_Rbm.Api$cmes_Auth.Is_Role_Assigned (
                       p_Cmes_Id         =>
                           Ikis_Rbm.Api$cmes_Auth.c_Cmes_Ss_Provider,
                       p_Cmes_Owner_Id   => p_Cmes_Owner_Id,
                       p_Cr_Code         => 'NSP_CM'))
        THEN
            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.At_Id
                  FROM Act a
                 WHERE     a.At_Main_Link = p_Tctr_Id
                       AND a.At_Rnspm = p_Cmes_Owner_Id
                       AND a.At_Tp = c_At_Tp
                       AND a.At_St <> c_At_St_Canceled
                       AND a.At_Dt BETWEEN NVL (p_At_Dt_Start, a.At_Dt)
                                       AND NVL (p_At_Dt_Stop, a.At_Dt)
                       AND (p_At_Num IS NULL OR a.At_Num LIKE p_At_Num || '%')
                       AND a.At_Src = NVL (p_At_Src, a.At_Src)
                       AND (   NVL (p_Need_Sign, 'F') = 'F'
                            OR a.At_St = c_At_St_Sign_Pr)
                       AND (   p_At_Spec_Name IS NULL
                            OR EXISTS
                                   (SELECT 1
                                      FROM Ikis_Rbm.v_Cmes_Users u
                                     WHERE     u.Cu_Id = a.At_Cu
                                           AND UPPER (u.Cu_Pib) LIKE
                                                      UPPER (p_At_Spec_Name)
                                                   || '%'));
        END IF;

        Get_Act_List (p_Acts);
        Get_Attributes (p_Attrs);
    END;

    -----------------------------------------------------------
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

    -----------------------------------------------------------
    --   ОТРИМАННЯ ОСНОВНИХ ДАНИХ ІНФОРМИЦІЇ ПРО ПРИПРИНЕННЯ
    -----------------------------------------------------------
    PROCEDURE Get_Act (p_At_Id IN NUMBER, p_Res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Res FOR
            SELECT a.At_Id,
                   a.At_Org,
                   o.Org_Name
                       AS At_Org_Name,
                   --Загальна інформація
                   --12. ПІБ законного представника / уповноваженої особи ОСП
                   Get_Agent_Pib (a.At_Ap)
                       AS At_Agent_Pib,
                   --8. Номер
                   a.At_Num,
                   --9. Дата реєстрації
                   a.At_Dt,
                   --10. Джерело
                   a.At_Src,
                   Sr.Dic_Name
                       AS At_Src_Name,
                   --12. Статус
                   a.At_St,
                   s.Dic_Name
                       AS At_St_Name,
                   --Ким сформовано форму ведення випадку
                   --Посада
                   Api$act.Get_At_Spec_Position (a.At_Wu,
                                                 a.At_Cu,
                                                 a.At_Rnspm)
                       AS At_Spec_Position,
                   --15. Прізвище особи, яка сформувала --16. Ім’я особи, яка сформувала --17. По - батькові особи, яка сформувала
                   Api$act.Get_At_Spec_Name (a.At_Wu, a.At_Cu)
                       AS At_Spec_Name,
                   --13. Назва НСП
                   a.At_Rnspm,
                   Uss_Rnsp.Api$find.Get_Nsp_Name (a.At_Rnspm)
                       AS At_Rnsp_Name,
                   --Повідомлення – попередження про припинення надання соціальних послуг щодо кого
                   --18. Прізвище особи --19. Ім’я особи  --20. По-батькові особи
                   a.At_Sc,
                   Uss_Person.Api$sc_Tools.Get_Pib (a.At_Sc)
                       AS At_Sc_Pib,
                   --Підписант (керівник) повідомлення
                   --26. Посада підписанта
                   Api$act.Get_Signer_Position (a.At_Id, 'PR')
                       AS At_Approver_Position,
                   --27. Прізвище підписанта --28. Ім’я підписанта --29. По-батькові підписанта
                   Api$act.Get_Signer_Pib (a.At_Id, 'PR')
                       AS At_Approver_Pib,
                   --Адреса для листування
                   a.At_Live_Address,
                   --ІД договору
                   t.At_Id
                       AS At_Tctr,
                   --9. Номер договору
                   t.At_Num
                       AS At_Tctr_Num,
                   --10. Дата договору
                   t.At_Dt
                       AS At_Tctr_Dt,
                   --Дата початку призупинення надання СП
                   a.At_Action_Start_Dt,
                   --Дата закінчення призупинення надання СП
                   a.At_Action_Stop_Dt,
                   Cmes$act.Get_Decline_Reason (a.at_id)
                       AS decline_reason,
                   api$act.Get_Attr_Val_Dt (a.at_id, 5358)
                       AS At_Med_Conclusion_Dt,
                   api$act.Get_Attr_Val_Str (a.at_id, 5359)
                       AS At_Med_Conclusion_Num,
                   api$act.Get_Attr_Val_Str (a.at_id, 5360)
                       AS At_Med_Contraindications
              FROM Act  a
                   JOIN Uss_Ndi.v_Ddn_At_Isnp_St s ON a.At_St = s.Dic_Value
                   JOIN Uss_Ndi.v_Ddn_Ap_Src Sr ON a.At_Src = Sr.Dic_Value
                   LEFT JOIN Uss_Ndi.v_Ndi_Reason_Not_Pay r
                       ON a.At_Rnp = r.Rnp_Id
                   LEFT JOIN Ikis_Sys.v_Opfu o ON a.At_Org = o.Org_Id
                   LEFT JOIN Act t ON a.At_Main_Link = t.At_Id
             WHERE a.At_Id = p_At_Id;
    END;

    -----------------------------------------------------------
    --     ОТРИМАННЯ ДАНИХ АКТУ
    -----------------------------------------------------------
    PROCEDURE Get_Act_Card (p_At_Id            IN     NUMBER,
                            p_Act_Cur             OUT SYS_REFCURSOR,
                            p_Docs_Cur            OUT SYS_REFCURSOR,
                            p_Docs_Files_Cur      OUT SYS_REFCURSOR,
                            p_Attrs_Cur           OUT SYS_REFCURSOR,
                            p_Signers_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        Write_Audit ('Get_Act_Card');
        Check_Act_Access (p_At_Id);

        Get_Act (p_At_Id, p_Act_Cur);
        Api$act.Get_Signers (p_At_Id, p_Signers_Cur);
        Api$act.Get_Documents (p_At_Id, p_Docs_Cur);
        Api$act.Get_Doc_Files (p_At_Id, p_Docs_Files_Cur);
        Api$act.Get_Doc_Attributes (p_At_Id, p_Attrs_Cur);
    --Get_Attributes(p_At_Id, p_Attrs_Cur);
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

        l_Ndt_Id := Api$act.Define_Print_Form_Ndt (p_At_Id, l_Build_Proc);
        /*Api$act.Get_Form_File(p_At_Id           => p_At_Id,
                              p_At_Prj_St       => c_At_St_Prj,
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
                p_At_St_Old   => c_At_St_Prj,
                p_At_St_New   => c_At_St_Sign_Pr,
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
        l_At_Id     NUMBER;
        l_At_Num    Act.At_Num%TYPE;
        l_Tctr_Id   NUMBER;
        l_Tctr_St   Act.At_St%TYPE;
        l_Pdsp_Id   NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Pr');
        l_At_Id := Api$act.Get_Atd_At (p_Atd_Id);
        Cmes$act.Set_Signed_Pr (p_At_Id       => l_At_Id,
                                p_Atd_Id      => p_Atd_Id,
                                p_file_code   => p_file_code);

        Api$act.Set_At_St (
            p_At_Id       => l_At_Id,
            p_At_St_Old   => c_At_St_Sign_Pr,
            p_At_St_New   => c_At_St_Signed_Pr,
            p_Log_Msg     => CHR (38) || '253',
            p_Wrong_St_Msg   =>
                'Затвердження надавачем можливо лише в стані "Очікує підписання"');

        SELECT a.At_Main_Link,
               a.At_Num,
               t.At_St,
               t.At_Main_Link
          INTO l_Tctr_Id,
               l_At_Num,
               l_Tctr_St,
               l_Pdsp_Id
          FROM Act a JOIN Act t ON a.At_Main_Link = t.At_Id
         WHERE a.At_Id = l_At_Id;

        --Змінюємо стан договору на "Призупинено"
        UPDATE Act a
           SET a.At_St = 'DPU'
         WHERE a.At_Id = l_Tctr_Id;

        --#102437
        api$act.set_ats_st (l_pdsp_id, 'SG', 'SU');

        Api$act.Write_At_Log (
            p_Atl_At        => l_Tctr_Id,
            p_Atl_Hs        => Tools.Gethistsessioncmes,
            p_Atl_St        => 'DPU',
            p_Atl_Message   => CHR (38) || '266#' || l_At_Num,
            p_Atl_St_Old    => l_Tctr_St);

        --Змінюємо статус інд. планів на "призупинено"
        FOR Rec
            IN (SELECT a.At_Id, a.At_St
                  FROM At_Links  l
                       JOIN Act a
                           ON     l.Atk_At = a.At_Id
                              AND a.At_Tp = 'IP'
                              AND a.At_St = 'IT'
                 WHERE l.Atk_Link_At = l_Pdsp_Id AND l.Atk_Tp = 'DECISION')
        LOOP
            UPDATE Act a
               SET a.At_St = 'ITU'
             WHERE a.At_Id = Rec.At_Id;

            Api$act.Write_At_Log (
                p_Atl_At        => Rec.At_Id,
                p_Atl_Hs        => Tools.Gethistsessioncmes,
                p_Atl_St        => 'ITU',
                p_Atl_Message   => CHR (38) || '266#' || l_At_Num,
                p_Atl_St_Old    => Rec.At_St);
        END LOOP;
    END;

    -----------------------------------------------------------
    -- БЕРЕЖЕННЯ ВІДМІТКИ ПРО НАКЛАДАННЯ ПІДПИСУ КМом
    -----------------------------------------------------------
    PROCEDURE Set_Signed_Cm (p_At_Id       IN     NUMBER,
                             p_file_code   IN     VARCHAR2,
                             p_Messages       OUT SYS_REFCURSOR)
    IS
        l_At_Id   NUMBER;
    BEGIN
        Write_Audit ('Set_Signed_Cm');
        Cmes$act.Set_Signed_Cm (p_At_Id       => p_At_Id,
                                p_Ndt_Id      => c_Form_Ndt,
                                p_file_code   => p_file_code);

        IF Api$act_Validation.Validate_Act (p_At_Id      => p_At_Id,
                                            p_Messages   => p_Messages)
        THEN
            Api$act.Set_At_St (
                p_At_Id       => l_At_Id,
                p_At_St_Old   => c_At_St_Prj,
                p_At_St_New   => c_At_St_Signed_CM,
                p_Log_Msg     => CHR (38) || '253',
                p_Wrong_St_Msg   =>
                    'Затвердження надавачем можливо лише в стані "Проект"');
        END IF;
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
            p_At_St_Old      => c_At_St_Prj,
            p_At_St_New      => c_At_St_Canceled,
            p_Log_Msg        => CHR (38) || '230#' || p_Reason,
            p_Wrong_St_Msg   => 'Скасування можливо лише в стані проекту');
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
END Cmes$act_Isnp;
/